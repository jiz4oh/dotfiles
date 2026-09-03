const reminder =
  "Before finishing meaningful engineering work, use $agents-memory to preserve only durable, evidence-backed project knowledge. Update the nearest repository memory only when something qualifies; preserve unrelated work."

export const AgentsMemoryPlugin = async () => ({
  "experimental.chat.system.transform": async (_input, output) => {
    if (!output.system.includes(reminder)) output.system.push(reminder)
  },
  "experimental.session.compacting": async (_input, output) => {
    if (!output.context.includes(reminder)) output.context.push(reminder)
  },
})
