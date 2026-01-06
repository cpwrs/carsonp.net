<script lang="ts">
  import "$lib/global.css";
</script>

<header>
  <nav>
    <a class="title" href="/">carsonp.net</a>
    <a href="/about">About</a>
    <a href="/projects">Projects</a>
  </nav>
</header>

<style>
  header {
    margin-bottom: 2ch;
    font-family: "EB Garamond";
    font-weight: 400;
    & nav {
      display: flex;
      column-gap: 2ch;
      align-items: baseline;
      flex-wrap: wrap;
    }
    & a {
      font-style: normal;
      color: var(--fg);
      text-decoration: none;
    }
    & a:hover {
      text-decoration: underline;
    }
    & .title {
      font-size: 1.2em;
      flex-grow: 2;
    }
  }
</style>
