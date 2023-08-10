module decompose

import config

pub fn identify_and_size(dir string, code_schema config.CodeSchema) ! {
	components := find_components(dir, code_schema)!
	components.print_table()
}
