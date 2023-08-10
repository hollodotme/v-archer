module decompose

import config
import os
import arrays
import strconv
import strings
import math

const trim_chars = ' \n\r\t\v\x00'

struct SoftwareComponent {
pub:
	name             string
	namespace        string
	count_files      int
	count_statements int
}

struct SoftwareComponents {
pub mut:
	components []SoftwareComponent [required]
}

pub fn (comps SoftwareComponents) get_total_statements() int {
	return arrays.sum[int](comps.components.map(fn (comp SoftwareComponent) int {
		return comp.count_statements
	})) or { 0 }
}

pub fn (comps SoftwareComponents) get_total_files() int {
	return arrays.sum[int](comps.components.map(fn (comp SoftwareComponent) int {
		return comp.count_files
	})) or { 0 }
}

fn (comps SoftwareComponents) get_names() []string {
	return comps.components.map(fn (comp SoftwareComponent) string {
		return comp.name
	})
}

fn (comps SoftwareComponents) get_namespaces() []string {
	return comps.components.map(fn (comp SoftwareComponent) string {
		return comp.namespace
	})
}

pub fn (comps SoftwareComponents) print_table() {
	total_statements := comps.get_total_statements()
	total_files := comps.get_total_files()
	max_name_len := get_max_len(comps.get_names())
	max_namespace_len := get_max_len(comps.get_namespaces())
	name_str := 'Name'
	namespace_str := 'Namespace'
	total_str := 'Totals'
	no_str := ''
	mut sum_percentage := 0

	unsafe {
		header := strconv.v_sprintf('%-${max_name_len}s  %-${max_namespace_len}s  Percent  Statements  Files',
			name_str, namespace_str)
		println(strings.repeat_string('-', header.len))
		println(header)
		println(strings.repeat_string('-', header.len))

		for component in comps.components {
			statement_percentage := int(math.round(f64(component.count_statements) / total_statements * 100))
			sum_percentage += statement_percentage

			line := strconv.v_sprintf('%-${max_name_len}s  %-${max_namespace_len}s  %7d  %10d  %5d',
				component.name, component.namespace, statement_percentage, component.count_statements,
				component.count_files)

			println(line)
		}
		println(strings.repeat_string('-', header.len))

		line := strconv.v_sprintf('%-${max_name_len}s  %-${max_namespace_len}s  %7d  %10d  %5d',
			total_str, no_str, sum_percentage, total_statements, total_files)

		println(line)
	}
}

fn get_max_len(elements []string) int {
	mut lengths := elements.map(fn (str string) int {
		return str.len
	})
	lengths.sort()
	return lengths.last()
}

pub fn find_components(base_dir string, code_schema config.CodeSchema) !SoftwareComponents {
	mut comps := SoftwareComponents{
		components: []SoftwareComponent{}
	}

	for dir in find_directories_recursive(base_dir)! {
		count_files, count_statements := count_files_and_statements(dir, code_schema)
		component_name := dir.all_after_last('/').to_upper()
		sub_namespace := dir.replace(base_dir, '').replace('/', '.').trim('.')
		comps.components << SoftwareComponent{
			name: component_name
			namespace: code_schema.get_namespace(sub_namespace)
			count_files: count_files
			count_statements: count_statements
		}
	}

	return comps
}

fn find_directories_recursive(base_dir string) ![]string {
	mut dirs := []string{}

	dir_filter := fn [base_dir] (entry string) bool {
		return os.is_dir(base_dir + '/' + entry)
	}

	for dir in os.ls(base_dir)!.filter(dir_filter).filter(dot_filter) {
		dirpath := base_dir + '/' + dir
		dirs << dirpath

		if !os.is_dir_empty(dirpath) {
			dirs << find_directories_recursive(base_dir + '/' + dir)!
		}
	}

	return dirs
}

fn dot_filter(entry string) bool {
	return entry[0..1] != '.'
}

fn count_files_and_statements(path string, code_schema config.CodeSchema) (int, int) {
	file_filter := fn [path] (entry string) bool {
		return os.is_file(path + '/' + entry)
	}

	files := (os.ls(path) or { []string{} }).filter(file_filter).filter(dot_filter)

	statements := files.map(fn [path, code_schema] (file string) int {
		return count_statements_in_file(path + '/' + file, code_schema)
	})

	return files.len, arrays.sum[int](statements) or { 0 }
}

fn count_statements_in_file(file string, code_schema config.CodeSchema) int {
	trimmer := fn (line string) string {
		return line.trim(decompose.trim_chars)
	}

	lines := os.read_file(file) or { '' }.split_into_lines()

	statements := lines.map(trimmer)
		.filter(fn (line string) bool {
			return '' != line
		}).filter(fn [code_schema] (line string) bool {
		return !line.starts_with(code_schema.comment_line_start)
	})

	return statements.len
}
