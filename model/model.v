// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module model

import ui
import math
import strings
import os
import regex

const autosave_filename = '~/.geomrc'

type AcceptFn = fn( Geom ) bool

type Id = u64

const cursor_expand = 2

pub enum Layer {
    lines = 0
    points
    //
    len
}

[heap]
pub struct Model {
    mut:
    geometry &map[u64]Geom = &map[u64]Geom{}
    layers [][]Id = [][]Id{ len: int( Layer.len ), init: []Id{} }
    last_id Id
    highlighted []Id = []Id{}
    selected []Id = []Id{}
}

pub fn new_model() Model {
    mut m := Model{}
    m.autoload()
    return m
}

fn (m Model) geometry( id Id ) Geom {
    unsafe {
        return m.geometry[ id ] or {
            panic( 'model.geometry() called with invalid id' )
        }
    }
}

fn (m Model) get_geom( id Id ) !Geom {
    unsafe {
        return m.geometry[ id ]
    }
}

fn (m Model) set_geom( id Id, geom Geom ) ! {
    unsafe {
        if _ := m.geometry[ id ] {
            return error( "model.set_geom() called with existing id" )
        }
        m.geometry[ id ] = geom
    }
}

pub fn (mut m Model) set_highlighted( g Geom ) {
    m.highlighted = [ g.id ]
}

pub fn (mut m Model) add_highlighted( g Geom ) {
    m.highlighted << g.id
}

pub fn (mut m Model) clear_highlighted() {
    m.highlighted = []
}

pub fn (mut m Model) test( x f64, y f64, accept AcceptFn ) Geom {
    mut best_d := math.max_f64
    mut best := Geom( None{} )
    for l := int( Layer.len ) - 1; l >= 0; l-- {
        for _, id in m.layers[ l ] {
            if mut g := m.get_geom( id ) {
                if accept( g ) {
                    d := g.test( x, y )
                    if d >= 0 && d < best_d {
                        best_d = d
                        best = g
                    }
                }
            }
        }
    }
    return best
}

pub fn (mut m Model) set_selected( g Geom ) {
    m.selected = [ g.id ]
}

pub fn (mut m Model) add_selected( g Geom ) {
    m.selected << g.id
}

pub fn (mut m Model) clear_selected() {
    m.selected = []
}

pub fn (mut m Model) add( mut g Geom, l Layer ) {
    m.last_id++
    id := m.last_id

    m.set_geom( id, g ) or { panic( err ) }
    m.layers[ l ] << id
    g.add( id )

    m.autosave()
}

pub fn (mut m Model) draw( d ui.DrawDevice, c ui.CanvasLayout ) {
    mut highlighted := []Id{}
    mut selected := []Id{}
    for l in 0 .. int( Layer.len ) {
        for _, id in m.layers[ l ] {
            if id in m.selected {
                selected << id
            } else if id in m.highlighted {
                highlighted << id
            } else {
                m.geometry( id ).draw( d, c, .normal )
            }
        }
    }
    for _, id in highlighted {
        m.geometry( id ).draw( d, c, .highlighted )
    }
    for _, id in selected {
        m.geometry( id ).draw( d, c, .selected )
    }
}

pub fn (mut m Model) remove( mut g Geom ) {
    mut ids := []Id{}
    m.gather_remove_geom( mut ids, g.id )

    for _, id in ids {
        m.highlighted = m.highlighted.filter( it != id )
        m.selected = m.selected.filter( it != id )
        for l in 0 .. int( Layer.len ) {
            m.layers[ l ] = m.layers[ l ].filter( it != id )
        }
        m.geometry.delete( id )
    }

    m.autosave()
}

fn (mut m Model) gather_remove_geom( mut ids []Id, id Id ) {
    mut g := m.get_geom( id ) or { return }
    ids << id
    for _, mut also in g.remove() {
        if also !in ids {
            m.gather_remove_geom( mut ids, also )
        }
    }
}

pub fn (mut m Model) autosave() {
    m.save( os.expand_tilde_to_home( autosave_filename ) ) or {
        println( "autosave: ${err}" )
    }
}

fn (mut m Model) save( filename string ) ! {
    mut f := os.create( filename )!
    defer { f.close() }

    // version
    mut out := strings.new_builder( 8 * 1024 )
    out.writeln( "geom/1" )

    // geometry
    out.writeln( "geometry" )
    for id, g in m.geometry {
        out.writeln( "${id}:${g.kind()}" )
        g.serialise( mut out )
    }
    out.writeln( "end" )

    wrote := f.write_string( out.str() )!
    if wrote < 1 {
        return error( "write failed" )
    }
}

pub fn (mut m Model) autoload() {
    m.load( os.expand_tilde_to_home( autosave_filename ) ) or {
        println( "autoload: ${err}" )
    }
}

fn (mut m Model) load( filename string ) ! {
    mut loader := new_loader( filename )!
    defer { loader.close() }

    // version
    load_version( mut loader )!

    // sections
    mut model := Model{}
    for true {
        line := loader.next_line()!
        if loader.eof() { break }
        match line {
            "geometry" {
                model.load_geometry( mut loader )!
            }
            else {
                return error( "bad section, line ${loader.line_no}" )
            }
        }
    }

    // apply
    m.clear_highlighted()
    m.clear_selected()
    m.geometry = model.geometry
    m.layers = model.layers
    m.last_id = model.last_id
}

fn (mut m Model) load_geometry( mut loader Loader ) ! {
    for true {
        line := loader.next_line()!
        if loader.eof() { break }
        if line == "end" { break }
        mut re := regex.regex_opt( "^([0-9]+):([-a-z]+)$" ) or { panic( err ) }
        if !re.matches_string( line ) {
            return error( "bad geometry data, line ${loader.line_no}" )
        }
        id := re.get_group_by_id( line, 0 ).u64()
        kind := re.get_group_by_id( line, 1 )

        if id > m.last_id { m.last_id = id }

        mut geom := Geom( None{} )
        match kind {
            "point" {
                geom = Geom( Point{} )
                m.layers[ Layer.points ] << id
            }
            "line" {
                geom = Geom( Line{} )
                m.layers[ Layer.lines ] << id
            }
            else {
                return error( "unknown geometry, line ${loader.line_no}" )
            }
        }
        geom.unserialise( mut loader, mut m )!

        // add
        m.set_geom( id, geom ) or {
            return error(
                "duplicate geometry, id ${id}, line ${loader.line_no}" )
        }
        geom.add( id )
    }
}

fn load_version( mut loader Loader ) ! {
    line := loader.next_line()!
    if line.len == 0 {
        return error( "empty file" )
    }
    mut re := regex.regex_opt( "^geom/([0-9]+)$" ) or { panic( err ) }
    if !re.matches_string( line ) {
        return error( "unknown file format" )
    }
    version := re.get_group_by_id( line, 0 ).int()
    if version < 1 {
        return error( "bad file format" )
    }
    if version > 1 {
        return error( "unknown (future!) data format" )
    }
    loader.version = version
}
