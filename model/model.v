// model.v
//
// Copyright (C) 2022 Tim Marston <tim@ed.am>
//
// This file is part of Geom (hereafter referred to as "this program").
// See http://github.com/edam/geom for more information.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

module model

import ui
import math

const filename = '~/.geomrc'

type AcceptFn = fn( Geom ) bool

pub enum Layer {
    lines = 0
    points
    //
    len
}

[heap]
pub struct Model {
    pub mut:
    highlighted Geom = None{}
    selected []Geom = []Geom{}
    geometry [][]Geom = [][]Geom{ len: int( Layer.len ), init: []Geom{} }
}

pub fn new_model() Model {
    mut m := Model{}
    /*m.load( filename )*/
    return m
}

pub fn (mut m Model) highlight( d Geom ) {
    m.highlighted = d
}

pub fn (mut m Model) unhighlight() {
    m.highlighted = None{}
}

pub fn (mut m Model) test( x f64, y f64, accept AcceptFn ) Geom {
    mut best_d := math.max_f64
    mut best := Geom( None{} )
    for l in 0 .. int( Layer.len ) {
        for _, g in m.geometry[ l ] {
            if accept( g ) {
                d := g.test( x, y )
                if d >= 0 && d < best_d {
                    best_d = d
                    best = g
                }
            }
        }
    }
    return best
}

pub fn (mut m Model) set_selected( d Geom ) {
    m.clear_selected()
    m.add_selected( d )
}

pub fn (mut m Model) add_selected( d Geom ) {
    m.selected << d
}

pub fn (mut m Model) clear_selected() {
    m.selected = []Geom{}
}

pub fn (mut m Model) add( mut g Geom, l Layer ) {
    m.geometry[ l ] << g
    g.add()

    m.autosave()
}

pub fn (mut m Model) draw( d ui.DrawDevice, c ui.CanvasLayout ) {
    for l in 0 .. int( Layer.len ) {
        for _, mut g in m.geometry[ l ] {
            if g in m.selected || m.highlighted == g { continue }
            g.draw( d, c, .normal )
        }
        mut selected := false
        for _, mut g in m.selected {
            g.draw( d, c, .selected )
            if g == m.highlighted { selected = true }
        }
        if !selected {
            if m.highlighted !is None {
                m.highlighted.draw( d, c, .highlighted )
            }
        }
    }
}

pub fn (mut m Model) remove( mut g Geom ) {
    mut set := []Geom{}
    m.remove_geom( mut set, mut g )

    for _, cg in set {
        if m.highlighted == g {
            m.highlighted = None{}
        }
        for i, sg in m.selected {
            if sg == cg {
                m.selected.delete( i )
                break
            }
        }
        skip:
        for _, mut layer in m.geometry {
            for i, lg in layer {
                if lg == cg {
                    layer.delete( i )
                    break skip
                }
            }
        }
    }

    m.autosave()
}

fn (mut m Model) remove_geom( mut set []Geom, mut g Geom ) {
    set << g
    for _, mut also in g.remove() {
        if also !in set {
            m.remove_geom( mut set, mut also )
        }
    }
}

fn (mut m Model) load( filename string ) {
}

fn (mut m Model) autosave() {
    m.save( filename )
}

fn (mut m Model) save( filename string ) {
    /*println( '-- save --' )*/
    /*mut r := map[string]string*/
    /*for l in 0 .. int( Layer.len ) {*/
    /*    for _, mut g in m.geometry[ l ] {*/
    /*        println( Geom( g ).hash() )*/
    /*        r[ g.hash() ] = g.serialize()*/
    /*    }*/
    /*}*/
    /*println( r )*/
}
