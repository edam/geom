// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module model

import ui
import gx
import math
import strings
import regex

//

/*pub struct InfLine {*/
/*pub:*/
/*    m f64*/
/*    c f64*/
/*}*/

//

const line_thickness = 4


pub struct Line {
//    InfLine
    pub mut:
    p1 &Point
    p2 &Point
    mut:
    id Id
}

// TODO: make references!
fn (l Line) ==( o Line ) bool {
    return l.id == o.id
}

fn (l Line) get_m_and_c() (f64, f64) {
    // TODO: this *should* be able to divide by zero, but it never does...
    m := ( l.p2.y - l.p1.y ) / ( l.p2.x - l.p1.x )
    c := l.p1.y - m * l.p1.x
    return m, c
}

pub fn (l Line) kind() string {
    return 'line'
}

pub fn (l Line) test( x f64, y f64 ) f64 {

    // see https://math.stackexchange.com/questions/2193720
    vx := l.p2.x - l.p1.x
    vy := l.p2.y - l.p1.y
    ux := l.p1.x - x
    uy := l.p1.y - y
    vu := vx * ux + vy * uy
    vv := vx * vx + vy * vy
    t := -vu / vv

    // outside line segment?
    if t < 0 || t > 1 { return -1 }

    // closest point on line is
    cx := t * l.p2.x + ( 1 - t ) * l.p1.x
    cy := t * l.p2.y + ( 1 - t ) * l.p1.y

    // distance
    d := Line{ p1: &Point{ x: x, y: y }, p2: &Point{ x: cx, y: cy } }.length()

    //m, c := l.get_m_and_c()
    //a := m
    //b := -1
    //d := math.abs( a * x + b * y + c ) / math.sqrt( a * a + b * b )

    return if d < line_thickness { d } else { -1 }
}

pub fn (l Line) draw( d ui.DrawDevice, c ui.CanvasLayout, how UIState ) {

    y := ( l.p2.y - l.p1.y ) / l.length()
    mut a := math.acos( y )
    if l.p2.x < l.p1.x { a = math.tau - a }

    match how {
        .cursor {
            mut s1t, mut c1t := math.sincos( a - math.pi_4 )
            mut s1b, mut c1b := math.sincos( a + math.pi_4 )
            mut s2t, mut c2t := math.sincos( a - 3 * math.pi_4 )
            mut s2b, mut c2b := math.sincos( a + 3 * math.pi_4 )
            cursor_thickness := line_thickness + cursor_expand
            s1t *= cursor_thickness
            c1t *= cursor_thickness
            s2t *= cursor_thickness
            c2t *= cursor_thickness
            s1b *= cursor_thickness
            c1b *= cursor_thickness
            s2b *= cursor_thickness
            c2b *= cursor_thickness

            c.draw_device_line( d, l.p1.x + s1t, l.p1.y + c1t, l.p2.x + s2t, l.p2.y + c2t, gx.black )
            c.draw_device_line( d, l.p1.x + s1b, l.p1.y + c1b, l.p2.x + s2b, l.p2.y + c2b, gx.black )
            c.draw_device_arc_line( d, l.p1.x, l.p1.y, point_radius + cursor_expand, f32( a + math.pi_4 ), f32( a + 7 * math.pi_4 ), 16, gx.black )
            c.draw_device_arc_line( d, l.p2.x, l.p2.y, point_radius + cursor_expand, f32( a - 3 * math.pi_4 ), f32( a + 3 * math.pi_4 ), 16, gx.black )
        }
        else {
            m, cc := l.get_m_and_c()
            c.draw_device_line( d, 0, cc, c.width, c.width * m + cc, gx.light_gray )

            mut sa, mut ca := math.sincos( a + math.pi_2 )
            ht := line_thickness / 2
            sa *= ht
            ca *= ht
            pts := [ f32(l.p1.x - sa), f32(l.p1.y - ca),
                     f32(l.p2.x - sa), f32(l.p2.y - ca),
                     f32(l.p2.x + sa), f32(l.p2.y + ca),
                     f32(l.p1.x + sa), f32(l.p1.y + ca) ]

            match how {
                .normal {
                    if l.p1 != l.p2 {
                        c.draw_device_convex_poly(d, pts, gx.gray )
                    }
                }
                .highlighted {
                    if l.p1 != l.p2 {
                        c.draw_device_convex_poly(d, pts, gx.light_gray )
                    }
                }
                .selected {
                    if l.p1 != l.p2 {
                        c.draw_device_convex_poly(d, pts, gx.black )
                    }
                }
                else {}
            }
        }
    }
}

pub fn (l Line) handle() ( f64, f64 ) {
    return l.p1.handle()
}

pub fn (mut l Line) move( x f64, y f64 ) {
    w := l.p2.x - l.p1.x
    h := l.p2.y - l.p1.y
    l.p1.move( x, y )
    l.p2.move( x + w, y + h )
}

fn (mut l Line) add( id Id ) {
    l.id = id
    l.p1.register_dep( l )
    l.p2.register_dep( l )
}

fn (mut l Line) remove() []Id {
    l.p1.unregister_dep( l )
    l.p2.unregister_dep( l )
    return []
}

pub fn (l Line) length() f64 {
    w := l.p2.x - l.p1.x
    h := l.p2.y - l.p1.y
    return math.sqrt( w * w + h * h )
}

fn (l Line) serialise( mut out strings.Builder ) {
    out.writeln( "#${l.p1.id},#${l.p2.id}" )
}

fn (mut l Line) unserialise( mut loader Loader, mut model Model ) !
{
    line := loader.next_line()!
    mut re := regex.regex_opt( "^#([0-9]+),#([0-9]+)$" ) or { panic( err ) }
    if !re.matches_string( line ) {
        return error( "bad line data, line ${loader.line_no}" )
    }
    geom1 := model.get_geom( re.get_group_by_id( line, 0 ).u64() ) or {
        return error( "point 1 id not found, line ${loader.line_no}" )
    }
    if geom1 is Point {
        l.p1 = geom1
    } else {
        return error( "point 1 id not a point, line {loader.line_no}" )
    }
    geom2 := model.get_geom( re.get_group_by_id( line, 1 ).u64() ) or {
        return error( "point 2 id not found, line ${loader.line_no}" )
    }
    if geom2 is Point {
        l.p2 = geom2
    } else {
        return error( "point 2 id not a point, line {loader.line_no}" )
    }
}
