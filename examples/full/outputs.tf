output "managed_ids" {
  description = "Managed certificate IDs by caller key."
  value       = module.certificates.managed_ids
}

output "uploaded_ids" {
  description = "Uploaded certificate IDs by caller key."
  value       = module.certificates.uploaded_ids
}
