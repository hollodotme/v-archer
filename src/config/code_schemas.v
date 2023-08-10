module config

import prantlf.yaml
import prantlf.jany

const (
	base_dir = './src/config'
)

enum ModuleIdentifier {
	directory
	namespace
}

fn ModuleIdentifier.from_name(name string) !ModuleIdentifier {
	return match name {
		'directory' { ModuleIdentifier.directory }
		'namespace' { ModuleIdentifier.namespace }
		else { error('Module identifier ${name} not implemented.') }
	}
}

pub struct CodeSchema {
pub:
	name                string           [required]
	statement_delimiter string           [required]
	comment_line_start  string           [required]
	comment_block_start string           [required]
	comment_block_end   string           [required]
	module_identifier   ModuleIdentifier [required]
	base_namespace      string
}

pub fn (code_schema CodeSchema) with_base_namespace(base_namespace string) CodeSchema {
	return CodeSchema{
		...code_schema
		base_namespace: base_namespace
	}
}

pub fn (code_schema CodeSchema) get_namespace(sub_namespace string) string {
	if '' == code_schema.base_namespace {
		return sub_namespace
	}

	return code_schema.base_namespace + '.' + sub_namespace
}

pub fn CodeSchema.load(schema_name string) !CodeSchema {
	filepath := config.base_dir + '/code_schemas/' + schema_name + '.yml'
	config := yaml.parse_file(filepath) or {
		panic('Cannot load schema config "${schema_name}" from file ${filepath}')
	}

	module_identifier := CodeSchema.get_config_value(schema_name, config, 'module_identifier')!

	return CodeSchema{
		name: CodeSchema.get_config_value(schema_name, config, 'name')!
		statement_delimiter: CodeSchema.get_config_value(schema_name, config, 'statement_delimiter')!
		comment_line_start: CodeSchema.get_config_value(schema_name, config, 'comment_line_start')!
		comment_block_start: CodeSchema.get_config_value(schema_name, config, 'comment_block_start')!
		comment_block_end: CodeSchema.get_config_value(schema_name, config, 'comment_block_end')!
		module_identifier: ModuleIdentifier.from_name(module_identifier)!
	}
}

fn CodeSchema.get_config_value(schema_name string, schema jany.Any, key string) !string {
	config_value := schema.get(key) or {
		return error('Value missing for CodeSchema.${key} in Schema ${schema_name}')
	}

	return config_value.str()
}
