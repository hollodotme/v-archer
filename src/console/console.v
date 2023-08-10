module console

import config
import cli { Command }
import os
import decompose
import credits

pub fn init_console(args []string) {
	mut console := Command{
		name: 'v-archer console'
		description: 'CLI interface for v-archer'
		version: credits.get_app_version()
	}
	mut identify_and_size_cmd := Command{
		name: 'identify-and-size'
		description: 'Identify and size components of a software'
		execute: identify_and_size
		required_args: 1
	}
	identify_and_size_cmd.add_flag(cli.Flag{
		flag: .string
		required: false
		name: 'schema'
		abbrev: 's'
		default_value: ['default']
		description: 'Code schema to be used for analysis'
	})
	identify_and_size_cmd.add_flag(cli.Flag{
		flag: .string
		required: false
		name: 'base_namespace'
		abbrev: 'b'
		default_value: ['']
		description: 'Base namespace for components'
	})
	console.add_command(identify_and_size_cmd)
	console.setup()
	console.parse(args)
}

fn identify_and_size(cmd Command) ! {
	dir := check_dir(cmd.args[0])!
	schema_name := cmd.flags.get_string('schema')!
	base_namespace := cmd.flags.get_string('base_namespace')!
	code_schema := config.CodeSchema.load(schema_name)!

	println('Scanning dir:\n${dir}\n')
	println('with code schema: ${code_schema.name}\n')
	if '' != base_namespace {
		println('with base namespace: ${base_namespace}\n')
	}

	decompose.identify_and_size(dir, code_schema.with_base_namespace(base_namespace))!
}

fn check_dir(path string) !string {
	if !os.is_dir(path) {
		return error('${path} is not a directory!')
	}

	return os.real_path(path)
}
