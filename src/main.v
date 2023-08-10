module main

import credits
import console
import os

fn main() {
	credits.print_credits()
	console.init_console(os.args)
}
