// tool.v
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

module win

import ui

interface Tool {
    name string
    title string
    mut:
    reset()
    draw( ui.DrawDevice, ui.CanvasLayout, f64, f64 )
    move( f64, f64 )
    down( f64, f64 )
    up( f64, f64 )
    menu( f64, f64 )
}
