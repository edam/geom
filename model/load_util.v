// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module model

import os

const loader_max_line_len = 4096

struct Loader {
    mut:
    file os.File
    buf []u8 = []u8{ len: loader_max_line_len }
    buf_len int
    line_no int
    pub mut:
    version int
}

fn new_loader( filename string ) !&Loader {
    return &Loader{
        file: os.open( filename )!
    }
}

fn (mut l Loader) read_line() ! {
    if l.file.eof() {
        return error( "unexpected end of file" )
    }

    l.buf_len = l.file.read_bytes_into_newline( mut &l.buf )!
    l.line_no++

    // chomp newlines
    for l.buf_len > 0 && l.buf[ l.buf_len - 1 ] in [ 10, 13 ] {
        l.buf[ l.buf_len - 1 ] = 0
        l.buf_len--
    }
}

fn (l Loader) line() string {
    return unsafe { tos_clone( l.buf.data ) }
}

fn (mut l Loader) next_line() !string {
    l.read_line()!
    return l.line()
}

fn (mut l Loader) eof() bool {
    return l.file.eof()
}

fn (mut l Loader) close() {
    l.file.close()
}
