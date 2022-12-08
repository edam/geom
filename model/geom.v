// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module model

import ui
import strings

pub enum UIState {
    normal
    highlighted
    selected
    cursor
}

interface Geom {
    id Id
    kind() string
    test( f64, f64 ) f64
    draw( ui.DrawDevice, ui.CanvasLayout, UIState )
    serialise( mut strings.Builder )
    handle() (f64, f64)
    mut:
    move( f64, f64 )
    add( Id )
    remove() []Id
    unserialise( mut Loader, mut Model ) !
}

// until we have ?Geom types, lets make a model.None type, which conforms to the
// Geom interface. TODO: should fix this
pub struct None{ id Id }
fn (_ None) kind() string { return '' }
fn (_ None) test( _ f64, _ f64 ) f64 { return 0 }
fn (_ None) draw( _ ui.DrawDevice, _ ui.CanvasLayout, _ UIState ) {}
fn (_ None) handle() ( f64, f64 ) { return 0, 0 }
fn (mut _ None) move( _ f64, _ f64 ) {}
fn (mut _ None) add( _ Id ) {}
fn (mut _ None) remove() []Id { return [] }
fn (_ None) serialise( mut _ strings.Builder ) {}
fn (_ None) unserialise( mut _ Loader, mut _ Model ) ! {}
