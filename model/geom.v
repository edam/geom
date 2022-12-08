// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

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
