// geom.v
//
// Copyright (C) 2022 Tim Marston <tim@edm.am>
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

pub enum UIState {
    normal
    selected
    highlighted
    cursor
}

interface Geom {
    test( f64, f64 ) f64
    draw( ui.DrawDevice, ui.CanvasLayout, UIState )
    mut:
    add()
    remove() []Geom
    //serialize() string
    //unserialize( map[string]Geom, string ) bool
}

/*fn (g Geom) hash() string {*/
/*    ptr := unsafe{ voidptr( g ) }*/
/*    return "$ptr"*/
/*}*/

// -

// until we have ?Geom types, lets make a model.None type, which conforms to the
// Geom interface. TODO: should fix this
pub struct None {}
fn (_ None) test( _ f64, _ f64 ) f64 { return 0 }
fn (_ None) draw( _ ui.DrawDevice, _ ui.CanvasLayout, _ UIState ) {}
fn (mut _ None) add() {}
fn (mut _ None) remove() []Geom { return [] }
//fn (mut _ None) serialize() string { return '' }
//fn (mut _ None) unserialize( _ map[string]Geom, g string ) bool { return true }
