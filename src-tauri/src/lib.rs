use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct LinkConfig {
    pub source: String,
    pub destination: String,
    pub required: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ProjectConfig {
    pub name: String,
    pub version: String,
    pub links: Vec<LinkConfig>,
}

#[tauri::command]
fn load_json_config(path: String) -> Result<ProjectConfig, String> {
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("Failed to read config file: {}", e))?;
    let config: ProjectConfig = serde_json::from_str(&content)
        .map_err(|e| format!("Failed to parse JSON: {}", e))?;
    Ok(config)
}

#[tauri::command]
fn create_directory(path: String) -> Result<String, String> {
    fs::create_dir_all(&path)
        .map_err(|e| format!("Failed to create directory: {}", e))?;
    Ok(format!("Directory created: {}", path))
}

#[tauri::command]
fn list_directory(path: String) -> Result<Vec<String>, String> {
    let entries = fs::read_dir(&path)
        .map_err(|e| format!("Failed to read directory: {}", e))?;
    
    let mut files = Vec::new();
    for entry in entries {
        if let Ok(entry) = entry {
            let metadata = entry.metadata().ok();
            let file_type = if let Some(ref meta) = metadata {
                if meta.is_dir() { "d" } else if meta.is_symlink() { "l" } else { "-" }
            } else { "?" };
            
            let name = entry.file_name().to_string_lossy().to_string();
            files.push(format!("{} {}", file_type, name));
        }
    }
    Ok(files)
}

#[tauri::command]
fn create_symlink(source: String, destination: String) -> Result<String, String> {
    let source_path = Path::new(&source);
    let dest_path = Path::new(&destination);
    
    if !source_path.exists() {
        return Err(format!("Source path does not exist: {}", source));
    }
    
    // Create parent directory if it doesn't exist
    if let Some(parent) = dest_path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create parent directory: {}", e))?;
    }
    
    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(&source_path, &dest_path)
            .map_err(|e| format!("Failed to create symlink: {}", e))?;
    }
    
    #[cfg(windows)]
    {
        if source_path.is_dir() {
            std::os::windows::fs::symlink_dir(&source_path, &dest_path)
                .map_err(|e| format!("Failed to create symlink: {}", e))?;
        } else {
            std::os::windows::fs::symlink_file(&source_path, &dest_path)
                .map_err(|e| format!("Failed to create symlink: {}", e))?;
        }
    }
    
    Ok(format!("Symlink created: {} -> {}", destination, source))
}

#[tauri::command]
fn delete_symlink(path: String) -> Result<String, String> {
    let link_path = Path::new(&path);
    
    if !link_path.exists() && !link_path.is_symlink() {
        return Err(format!("Path does not exist: {}", path));
    }
    
    fs::remove_file(&link_path)
        .map_err(|e| format!("Failed to delete symlink: {}", e))?;
    
    Ok(format!("Symlink deleted: {}", path))
}

#[tauri::command]
fn process_project_links(config: ProjectConfig) -> Result<Vec<String>, String> {
    let mut results = Vec::new();
    
    for link in config.links {
        let result = create_symlink(link.source.clone(), link.destination.clone());
        match result {
            Ok(msg) => results.push(msg),
            Err(e) => {
                if link.required {
                    return Err(format!("Failed to create required link: {}", e));
                } else {
                    results.push(format!("Warning: {}", e));
                }
            }
        }
    }
    
    Ok(results)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_fs::init())
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            load_json_config,
            create_directory,
            list_directory,
            create_symlink,
            delete_symlink,
            process_project_links
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
