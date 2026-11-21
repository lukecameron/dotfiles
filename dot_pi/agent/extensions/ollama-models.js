// Registers every chat model the local Ollama server has pulled as the
// "ollama" provider. The list is read from Ollama at startup and again each
// time /model opens, so `ollama pull` and `ollama rm` need no pi config change.

const PROVIDER = "ollama";
const OLLAMA_URL = normalizeHost(process.env.OLLAMA_HOST || "127.0.0.1:11434");

// Ollama's OpenAI-compatible endpoint cannot set the context size per request:
// the server's OLLAMA_CONTEXT_LENGTH decides it. pi cannot read the server's
// environment, so it assumes the size the dotfiles' Ollama agent serves unless
// OLLAMA_CONTEXT_LENGTH is also set where pi runs.
const SERVED_CONTEXT = Number(process.env.OLLAMA_CONTEXT_LENGTH) || 32768;

// Local models can reason in loops, so output is capped well below the context.
const MAX_OUTPUT_TOKENS = 8192;

const STARTUP_TIMEOUT_MS = 1500;

function normalizeHost(host) {
  const url = /^https?:\/\//.test(host) ? host : `http://${host}`;
  return url.replace(/\/+$/, "");
}

async function ollama(path, signal, body) {
  const response = await fetch(`${OLLAMA_URL}${path}`, {
    method: body ? "POST" : "GET",
    headers: body ? { "content-type": "application/json" } : undefined,
    body: body ? JSON.stringify(body) : undefined,
    signal,
  });
  if (!response.ok) throw new Error(`Ollama ${path} returned ${response.status}`);
  return response.json();
}

function trainedContext(modelInfo) {
  for (const [key, value] of Object.entries(modelInfo || {})) {
    if (key.endsWith(".context_length") && Number(value) > 0) return Number(value);
  }
  return undefined;
}

async function describe(name, signal) {
  const show = await ollama("/api/show", signal, { model: name });
  const capabilities = show.capabilities || [];
  if (!capabilities.includes("completion")) return undefined;

  const contextWindow = Math.min(trainedContext(show.model_info) || SERVED_CONTEXT, SERVED_CONTEXT);
  const reasoning = capabilities.includes("thinking");
  return {
    id: name,
    name,
    reasoning,
    // Ollama accepts reasoning_effort low, medium and high, and "none" to turn thinking off.
    thinkingLevelMap: reasoning ? { off: "none", minimal: "low" } : undefined,
    input: capabilities.includes("vision") ? ["text", "image"] : ["text"],
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow,
    maxTokens: Math.min(MAX_OUTPUT_TOKENS, Math.floor(contextWindow / 2)),
    compat: { supportsStore: false, supportsDeveloperRole: false, maxTokensField: "max_tokens" },
  };
}

async function discover(signal) {
  const { models = [] } = await ollama("/api/tags", signal);
  const described = await Promise.all(models.map((model) => describe(model.name, signal)));
  return described.filter(Boolean).sort((a, b) => a.id.localeCompare(b.id));
}

export default async function ollamaModels(pi) {
  let models = [];
  try {
    models = await discover(AbortSignal.timeout(STARTUP_TIMEOUT_MS));
  } catch {
    // Ollama is not running. /model tries again when it opens.
  }

  pi.registerProvider(PROVIDER, {
    name: "Ollama",
    baseUrl: `${OLLAMA_URL}/v1`,
    api: "openai-completions",
    // Ollama ignores the key, but pi lists only providers that have one.
    apiKey: "ollama",
    models,
    refreshModels: (context) => discover(context.signal),
  });
}
