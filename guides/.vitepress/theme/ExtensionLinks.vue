<script setup>
import { ref, computed, onMounted } from "vue"
import { CURRENT_VERSION } from "../versions.js"

const props = defineProps({
  gem: String,
  github: String,
})

const alchemyRequirements = ref(null)
const rubygemsUrl = `https://rubygems.org/gems/${props.gem}`
const gemBadgeUrl = `https://img.shields.io/gem/v/${props.gem}?label=gem`

function versionSupport(requirements) {
  const parts = requirements.split(",").map((s) => s.trim())
  let upperBound = null
  for (const part of parts) {
    const match = part.match(/^<\s*(\d+(\.\d+)?)/)
    if (match) {
      upperBound = parseFloat(match[1])
      break
    }
  }
  if (upperBound === null || upperBound > CURRENT_VERSION) return "current"
  if (upperBound > CURRENT_VERSION - 1) return "legacy"
  return "unsupported"
}

const alchemyBadgeUrl = computed(() => {
  if (!alchemyRequirements.value) return null
  const support = versionSupport(alchemyRequirements.value)
  const color =
    support === "current" ? "2ea44f" : support === "legacy" ? "orange" : "red"
  let message = alchemyRequirements.value
  const minMatch = alchemyRequirements.value.match(/>=?\s*(\d+(\.\d+)?)/)
  if (minMatch) {
    message = ">= " + minMatch[1]
  }
  const params = new URLSearchParams({
    label: "alchemy",
    message,
    color,
  })
  return `https://img.shields.io/static/v1?${params}`
})

onMounted(async () => {
  try {
    const res = await fetch(
      `https://rubygems.org/api/v1/gems/${props.gem}.json`
    )
    if (res.ok) {
      const data = await res.json()
      const alchemyDep = data.dependencies.runtime.find(
        (dep) => dep.name === "alchemy_cms"
      )
      if (alchemyDep) {
        alchemyRequirements.value = alchemyDep.requirements
      }
    }
  } catch {
    // silently fail
  }
})
</script>

<template>
  <div class="extension-info">
    <div class="extension-badges">
      <a :href="rubygemsUrl" target="_blank" rel="noopener noreferrer">
        <img :src="gemBadgeUrl" alt="Gem version" loading="lazy" />
      </a>
      <img
        v-if="alchemyBadgeUrl"
        :src="alchemyBadgeUrl"
        alt="Alchemy version"
        loading="lazy"
      />
    </div>
    <div class="extension-links">
      <a :href="github" target="_blank" rel="noopener noreferrer">
        <svg
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"
          />
        </svg>
        GitHub
      </a>
      <a :href="rubygemsUrl" target="_blank" rel="noopener noreferrer">
        <svg
          width="16"
          height="16"
          viewBox="0 0 200 200"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            d="M68.8 69.9l-.1-.1L46.5 92l53.9 53.8 22.2-22.1L154.3 92l-22.2-22.2v-.1H68.7"
          />
          <path
            d="M100.2 10.6l-78.5 45v90l78.5 45 78.5-45v-90l-78.5-45zM163.7 137l-63.5 36.6L36.7 137V64l63.5-36.6L163.7 64v73z"
          />
        </svg>
        RubyGems
      </a>
    </div>
  </div>
</template>

<style scoped>
.extension-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.extension-badges {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.extension-badges img {
  height: 20px;
}

.extension-links {
  display: flex;
  gap: 1rem;
}

.extension-links a {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  text-decoration: none;
  transition: color 0.25s;
  white-space: nowrap;
}

.extension-links a:hover {
  color: var(--vp-c-brand-1);
}

.extension-links svg {
  flex-shrink: 0;
}
</style>
