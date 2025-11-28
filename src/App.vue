<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { invoke } from '@tauri-apps/api/core'
import Card from './components/ui/Card.vue'
import CardHeader from './components/ui/CardHeader.vue'
import CardTitle from './components/ui/CardTitle.vue'
import CardContent from './components/ui/CardContent.vue'
import Button from './components/ui/Button.vue'

interface LinkConfig {
  source: string
  destination: string
  required: boolean
}

interface ProjectConfig {
  name: string
  version: string
  links: LinkConfig[]
}

const configPath = ref('')
const directoryPath = ref('')
const sourcePath = ref('')
const destinationPath = ref('')
const symlinkPath = ref('')
const output = ref<string[]>([])
const directoryListing = ref<string[]>([])
const projectConfig = ref<ProjectConfig | null>(null)
const isLoading = ref(false)

const addOutput = (message: string) => {
  output.value.unshift(`[${new Date().toLocaleTimeString()}] ${message}`)
  if (output.value.length > 50) {
    output.value.pop()
  }
}

const loadConfig = async () => {
  if (!configPath.value) {
    addOutput('Error: Please enter a config path')
    return
  }
  
  isLoading.value = true
  try {
    const config = await invoke<ProjectConfig>('load_json_config', { path: configPath.value })
    projectConfig.value = config
    addOutput(`Loaded config: ${config.name} v${config.version}`)
    addOutput(`Found ${config.links.length} links`)
  } catch (error) {
    addOutput(`Error loading config: ${error}`)
  } finally {
    isLoading.value = false
  }
}

const createDirectory = async () => {
  if (!directoryPath.value) {
    addOutput('Error: Please enter a directory path')
    return
  }
  
  isLoading.value = true
  try {
    const result = await invoke<string>('create_directory', { path: directoryPath.value })
    addOutput(result)
  } catch (error) {
    addOutput(`Error: ${error}`)
  } finally {
    isLoading.value = false
  }
}

const listDirectory = async () => {
  if (!directoryPath.value) {
    addOutput('Error: Please enter a directory path')
    return
  }
  
  isLoading.value = true
  try {
    const files = await invoke<string[]>('list_directory', { path: directoryPath.value })
    directoryListing.value = files
    addOutput(`Listed ${files.length} entries in ${directoryPath.value}`)
  } catch (error) {
    addOutput(`Error: ${error}`)
    directoryListing.value = []
  } finally {
    isLoading.value = false
  }
}

const createSymlink = async () => {
  if (!sourcePath.value || !destinationPath.value) {
    addOutput('Error: Please enter source and destination paths')
    return
  }
  
  isLoading.value = true
  try {
    const result = await invoke<string>('create_symlink', { 
      source: sourcePath.value, 
      destination: destinationPath.value 
    })
    addOutput(result)
  } catch (error) {
    addOutput(`Error: ${error}`)
  } finally {
    isLoading.value = false
  }
}

const deleteSymlink = async () => {
  if (!symlinkPath.value) {
    addOutput('Error: Please enter a symlink path')
    return
  }
  
  isLoading.value = true
  try {
    const result = await invoke<string>('delete_symlink', { path: symlinkPath.value })
    addOutput(result)
  } catch (error) {
    addOutput(`Error: ${error}`)
  } finally {
    isLoading.value = false
  }
}

const processLinks = async () => {
  if (!projectConfig.value) {
    addOutput('Error: Please load a project config first')
    return
  }
  
  isLoading.value = true
  try {
    const results = await invoke<string[]>('process_project_links', { config: projectConfig.value })
    results.forEach(result => addOutput(result))
    addOutput('All links processed!')
  } catch (error) {
    addOutput(`Error: ${error}`)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  addOutput('Link Manager initialized')
})
</script>

<template>
  <div class="min-h-screen bg-gray-900 text-white p-6">
    <div class="max-w-6xl mx-auto">
      <h1 class="text-3xl font-bold text-center mb-8 text-blue-400">
        🔗 Symlink Manager
      </h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Load Config Section -->
        <Card class="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle class="text-blue-400">📄 Load JSON Config</CardTitle>
          </CardHeader>
          <CardContent>
            <input
              v-model="configPath"
              type="text"
              placeholder="/path/to/config.json"
              class="w-full p-2 mb-3 bg-gray-700 border border-gray-600 rounded text-white placeholder-gray-400"
            />
            <Button @click="loadConfig" :disabled="isLoading" class="w-full bg-blue-600 hover:bg-blue-700 text-white">
              Load Config
            </Button>
            
            <div v-if="projectConfig" class="mt-4 p-3 bg-gray-700 rounded">
              <p class="font-semibold">Project: {{ projectConfig.name }}</p>
              <p>Version: {{ projectConfig.version }}</p>
              <p>Links: {{ projectConfig.links.length }}</p>
              <Button @click="processLinks" :disabled="isLoading" class="mt-3 w-full bg-green-600 hover:bg-green-700 text-white">
                Process All Links
              </Button>
            </div>
          </CardContent>
        </Card>

        <!-- Directory Operations Section -->
        <Card class="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle class="text-green-400">📁 Directory Operations</CardTitle>
          </CardHeader>
          <CardContent>
            <input
              v-model="directoryPath"
              type="text"
              placeholder="/path/to/directory"
              class="w-full p-2 mb-3 bg-gray-700 border border-gray-600 rounded text-white placeholder-gray-400"
            />
            <div class="flex gap-2">
              <Button @click="createDirectory" :disabled="isLoading" class="flex-1 bg-green-600 hover:bg-green-700 text-white">
                Create Dir
              </Button>
              <Button @click="listDirectory" :disabled="isLoading" class="flex-1 bg-yellow-600 hover:bg-yellow-700 text-white">
                List Dir
              </Button>
            </div>
            
            <div v-if="directoryListing.length > 0" class="mt-4 p-3 bg-gray-700 rounded max-h-40 overflow-y-auto">
              <p class="font-semibold mb-2">Directory Contents:</p>
              <div v-for="(entry, idx) in directoryListing" :key="idx" class="text-sm font-mono">
                {{ entry }}
              </div>
            </div>
          </CardContent>
        </Card>

        <!-- Create Symlink Section -->
        <Card class="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle class="text-purple-400">🔗 Create Symlink</CardTitle>
          </CardHeader>
          <CardContent>
            <input
              v-model="sourcePath"
              type="text"
              placeholder="Source path"
              class="w-full p-2 mb-3 bg-gray-700 border border-gray-600 rounded text-white placeholder-gray-400"
            />
            <input
              v-model="destinationPath"
              type="text"
              placeholder="Destination path"
              class="w-full p-2 mb-3 bg-gray-700 border border-gray-600 rounded text-white placeholder-gray-400"
            />
            <Button @click="createSymlink" :disabled="isLoading" class="w-full bg-purple-600 hover:bg-purple-700 text-white">
              Create Symlink
            </Button>
          </CardContent>
        </Card>

        <!-- Delete Symlink Section -->
        <Card class="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle class="text-red-400">🗑️ Delete Symlink</CardTitle>
          </CardHeader>
          <CardContent>
            <input
              v-model="symlinkPath"
              type="text"
              placeholder="Symlink path to delete"
              class="w-full p-2 mb-3 bg-gray-700 border border-gray-600 rounded text-white placeholder-gray-400"
            />
            <Button @click="deleteSymlink" :disabled="isLoading" class="w-full bg-red-600 hover:bg-red-700 text-white">
              Delete Symlink
            </Button>
          </CardContent>
        </Card>
      </div>

      <!-- Output Log Section -->
      <Card class="mt-6 bg-gray-800 border-gray-700">
        <CardHeader>
          <CardTitle class="text-gray-300">📋 Output Log</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="bg-gray-900 p-4 rounded max-h-60 overflow-y-auto font-mono text-sm">
            <div v-for="(line, idx) in output" :key="idx" class="text-gray-300 py-1 border-b border-gray-800">
              {{ line }}
            </div>
            <div v-if="output.length === 0" class="text-gray-500 italic">
              No output yet...
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<style scoped>
/* Additional styles if needed */
</style>
