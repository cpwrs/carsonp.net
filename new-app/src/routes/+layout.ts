import { PUBLIC_COMMIT } from '$env/static/public';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async ({ data }) => {
  return {
    ...data,
    commit: PUBLIC_COMMIT || null
  }
}
