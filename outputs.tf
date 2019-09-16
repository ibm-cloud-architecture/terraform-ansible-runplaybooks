output "module_completed" {
    value = "${join(",", null_resource.run_playbook.*.id)}"
}