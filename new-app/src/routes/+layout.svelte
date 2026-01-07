<script lang="ts">
  import favicon from "$lib/favicon.png";
  import "$lib/global.css";
  import Header from "$lib/components/Header.svelte";
  import Contributions from "$lib/components/Contributions.svelte";

  let { data, children } = $props();

  function fakeContributions(): number[][] {
    let contrib = new Array(52); // 52 weeks
    for (let w = 0; w < contrib.length; w++) {
      contrib[w] = new Array(7);
      let week = contrib[w];
      for (let d = 0; d < week.length; d++) {
        week[d] = Math.floor(Math.pow(Math.random(), 8) * 21);
      }
    }
    return contrib;
  }
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>

<Header />
{#if data.prod}
  {#if data.contributions}
    {#await data.contributions then contributions}
      <Contributions {contributions} />
    {/await}
  {/if}
{:else}
  <Contributions contributions={fakeContributions()} />
{/if}

{@render children()}
