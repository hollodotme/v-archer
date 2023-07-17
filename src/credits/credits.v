module credits

import os
import v.vmod

pub fn print_credits() {
	println(get_app_name())
	println(get_app_version())
	println(get_authors())
}

fn get_app_name() string {
	return os.read_file('./src/credits/name.txt') or { panic(err) }
}

fn get_app_version() string {
	mod := vmod.decode(@VMOD_FILE) or { panic('Error decoding v.mod') }
	return '${mod.name} has version ${mod.version}'
}

fn get_authors() string {
	return os.read_file('./src/credits/authors.txt') or { panic(err) }
}
