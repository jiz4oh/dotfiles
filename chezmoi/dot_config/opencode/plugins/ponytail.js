import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const root = join(homedir(), '.agents/skill-sources/ponytail');
const require = createRequire(import.meta.url);
const { getPonytailInstructions } = require(join(root, 'hooks/ponytail-instructions.js'));
const { getDefaultMode, normalizePersistedMode } = require(join(root, 'hooks/ponytail-config.js'));
const state = join(process.env.XDG_CONFIG_HOME || join(homedir(), '.config'), 'opencode/.ponytail-active');

function mode() {
  try {
    return normalizePersistedMode(readFileSync(state, 'utf8').trim()) || getDefaultMode();
  } catch {
    return getDefaultMode();
  }
}

export default {
  id: 'ponytail',
  async setup(ctx) {
    await ctx.session.hook('context', (event) => {
      const level = mode();
      if (level !== 'off') event.system.push({ type: 'text', text: getPonytailInstructions(level) });
    });
  },
};

