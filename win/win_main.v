// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui
import gx
import model

[heap]
struct MainWindow {
    mut:
    win &ui.Window
    tools map[string]Tool
    tool string
    last_tool string
    mouse struct {
        mut:
        on bool
        x f64
        y f64
    }
    model model.Model
}

pub fn (mw MainWindow) run() {
	ui.run( mw.win )
}

pub fn new_main_window() &MainWindow {
    mut mw := &MainWindow{
        win: 0
        tools: map[string]Tool{}
        model: model.new_model()
    }
    mut btns := []ui.Widget{}
    add_tool := fn[ mut mw, mut btns ]( tool Tool ) []ui.Widget {
        mw.tools[ tool.name ] = tool
        btns << ui.button(
		    id: tool.name
		    text: tool.title
		    on_click: mw.tool_click
	    )
        return btns
    }
    btns = add_tool( new_select_tool( mut mw.model ) )
    btns = add_tool( new_point_tool( mut mw.model ) )
    btns = add_tool( new_line_tool( mut mw.model ) )
    btns = add_tool( new_clear_tool( mut mw.model ) )
    mw.win = ui.window(
		width: 600
		height: 400
		title: "Geom"
		mode: .resizable
		on_init: mw.init_window
        on_mouse_move: mw.on_mouse_move
		on_key_down: mw.on_key_down
        on_resize: mw.on_resize
        on_unfocus: mw.on_unfocus
        children: [
			ui.column(
				margin: ui.Margin{ 10, 10, 10, 10 }
				spacing: 10
				heights: [ ui.stretch, 30.0 ]
				children: [
					ui.canvas_layout(
                        id: 'canvas'
						bg_color: gx.white
						bg_radius: .025
                        scrollview: true,
						on_draw: mw.on_draw
                        on_mouse_down: mw.on_mouse_down
                        on_mouse_up: mw.on_mouse_up
					),
					ui.row(
                        id: 'tool_row'
						spacing: 10
						widths: ui.stretch
						children: btns
					)
				]
			)
		]
	)
    return mw
}

fn (mw MainWindow) get_tool_btn( name string ) &ui.Button {
	mut row := mw.win.stack( 'tool_row' )
	for _, mut btn in row.children {
		if mut btn is ui.Button {
            if btn.id == name {
                return btn
            }
		}
	}
    panic( "get_tool() request for invalid button: ${name}" )
}

fn (mut mw MainWindow)init_window( mut w ui.Window ) {
    mw.select_tool( 'select' )
}

fn (mut mw MainWindow) tool_click( mut b ui.Button ) {
    mw.select_tool( b.id )
}

fn (mut mw MainWindow) select_last_tool() {
    mw.select_tool( mw.last_tool )
}

fn (mut mw MainWindow) select_tool( name string ) {
    mw.model.clear_highlighted()
    mw.model.clear_selected()

    // deactivate
    if mw.tool.len > 0 {
        mut btn := mw.get_tool_btn( mw.tool )
        btn.disabled = false
        mw.tools[ mw.tool ].inactive( mut mw )
    }

    mw.last_tool = mw.tool

    // activate
    mut btn := mw.get_tool_btn( name )
    btn.disabled = true
    mut f := ui.Focusable( btn )
    f.set_focus()
    mw.tool = name
    mw.tools[ mw.tool ].active( mut mw )
}

fn (mut mw MainWindow) on_key_down( w &ui.Window, e ui.KeyEvent ) {
    if e.key == .escape {
        // TODO: w.close() not implemented (no multi-window support yet!)
        if w.ui.dd is ui.DrawDeviceContext {
            w.ui.dd.quit()
        }
    }
}

fn (mut mw MainWindow) on_draw( d ui.DrawDevice, c &ui.CanvasLayout ) {

    /*s := f32(math.max(0,int(mw.mouse.x)))/100.0 * math.pi*/
    /*l := f32(math.max(0,int(mw.mouse.y)))/100.0 * math.pi*/
    /*println( "$s $l" )*/

    /*c.draw_device_arc_empty( d, 100, 100, 50, 0, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_empty( d, 200, 100, 0, 10, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_empty( d, 300, 100, -10, 25, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_empty( d, 400, 100, 45, 10, s, s + l, 8, gx.black )*/

    /*c.draw_device_arc_filled( d, 100, 200, 50, 0, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_filled( d, 200, 200, 0, 10, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_filled( d, 300, 200, -10, 25, s, s + l, 8, gx.black )*/
    /*c.draw_device_arc_filled( d, 400, 200, 45, 10, s, s + l, 8, gx.black )*/

    /*for i in 0..100 {*/
    /*    c.draw_device_pixel(d, i, i, gx.black)*/
    /*}*/

    // ----

    //x := c.x + c.offset_x
    //y := c.y + c.offset_y
    //d.scissor_rect( x, y, c.width, c.height )

    mw.model.draw( d, c )

    if mw.mouse.on {
        if mut tool := mw.tools[ mw.tool ] {
            tool.draw( d, c, mw.mouse.x, mw.mouse.y )
        }
    }

    //d.scissor_rect( 0, 0, mw.win.width, mw.win.height )
}

fn (mut mw MainWindow) on_mouse_down( c &ui.CanvasLayout, e ui.MouseEvent ) {
    if e.button == .left {
        mut tool := mw.tools[ mw.tool ] or { return }
        tool.down( mw.mouse.x, mw.mouse.y )
    }
}

fn (mut mw MainWindow) on_mouse_up( c &ui.CanvasLayout, e ui.MouseEvent ) {
    if e.button == .left {
        mut tool := mw.tools[ mw.tool ] or { return }
        tool.up( mw.mouse.x, mw.mouse.y )
    } else if e.button == .right {
        mut tool := mw.tools[ mw.tool ] or { return }
        tool.menu( mw.mouse.x, mw.mouse.y )
    }
}

fn (mut mw MainWindow) on_mouse_move( w &ui.Window, e ui.MouseMoveEvent ) {
    c := w.canvas_layout( 'canvas' )
    mw.mouse.x = f64( e.x ) - c.x - c.offset_x
    mw.mouse.y = f64( e.y ) - c.y - c.offset_y
    mw.mouse.on = true

    mut tool := mw.tools[ mw.tool ] or { return }
    tool.move( mw.mouse.x, mw.mouse.y )
}

fn (mut mw MainWindow) on_resize( w &ui.Window, width int, height int ) {
    mw.mouse.on = false
}

fn (mut mw MainWindow) on_unfocus( w &ui.Window ) {
    mw.mouse.on = false
}
