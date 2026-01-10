<script lang="ts">
  export let commit: string;
  import rss from "$lib/rss.svg";
  import git from "$lib/git.svg";
</script>

<nav>
  <a
    href="https://github.com/cpwrs/carsonp.net/tree/{commit}"
    aria-label="View commit {commit} on GitHub"
  >
    <img class="icon" src={git} alt="Git Logo" />
    <span>Source</span>
  </a>
  <a href="/">
    <img class="icon" src={rss} alt="RSS Logo" />
    <span>RSS</span>
  </a>
</nav>

<style>
  nav {
    margin-top: auto;
    display: flex;
    column-gap: 2ch;
    align-items: center;
    flex-wrap: wrap;
    justify-content: flex-end;
    & a {
      display: flex;
      align-items: baseline;
      gap: 0.5ch;
      text-decoration: none;
    }
    & a:hover span {
      text-decoration: underline;
    }
  }
  .icon {
    width: 1.5ch;
    height: auto;
  }
</style>
