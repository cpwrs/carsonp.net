<script lang="ts">
  import favicon from "$lib/favicon.png";
  import "$lib/global.css";
  import Header from "$lib/components/Header.svelte";
  import Footer from "$lib/components/Footer.svelte";
  import Contributions from "$lib/components/Contributions.svelte";

  let { data, children } = $props();
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>

<Header />
{#await data.contributions then contributions}
  <Contributions {contributions} />
{/await}

{@render children()}

<Footer commit={data.commit} />
