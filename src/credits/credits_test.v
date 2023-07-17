module credits

import os
import v.vmod

fn test_get_app_name() {
	assert get_app_name() == os.read_file('./src/credits/name.txt')!
}

fn test_get_app_version() {
	mod := vmod.decode(@VMOD_FILE) or { panic('Error decoding v.mod') }
	assert get_app_version() == '${mod.name} has version ${mod.version}'
}
