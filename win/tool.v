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
