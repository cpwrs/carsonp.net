<script lang="ts">
  export let contributions: number[][];

  const BOX_SIZE = 40;
  const NO_COLOR = { r: 248, g: 247, b: 243 };
  const LOW_COLOR = { r: 238, g: 246, b: 238 };
  const HIGH_COLOR = { r: 83, g: 217, b: 156 };

  function maxCount(contributions: number[][]) {
    let max = 0;
    for (let w = 0; w < contributions.length; w++) {
      let week = contributions[w];
      for (let d = 0; d < week.length; d++) {
        let count = week[d];
        if (count > max) {
          max = count;
        }
      }
    }
    return max;
  }

  function getColor(count: number, max: number) {
    if (count === 0) {
      return `rgb(${NO_COLOR.r}, ${NO_COLOR.g}, ${NO_COLOR.b})`;
    }
    const percent = count / max;
    const r = Math.round(LOW_COLOR.r + (HIGH_COLOR.r - LOW_COLOR.r) * percent);
    const g = Math.round(LOW_COLOR.g + (HIGH_COLOR.g - LOW_COLOR.g) * percent);
    const b = Math.round(LOW_COLOR.b + (HIGH_COLOR.b - LOW_COLOR.b) * percent);
    return `rgb(${r}, ${g}, ${b})`;
  }

  $: width = contributions.length * BOX_SIZE;
  $: height = 7 * BOX_SIZE;
  $: max = maxCount(contributions);
</script>

<a href="https://github.com/cpwrs" class="contrib-container">
  {#each [false, true] as isClone}
    <svg
      viewBox="0 0 {width} {height}"
      style="height: 100%;"
      aria-hidden={isClone}
    >
      {#each contributions as week, w}
        {#each week as count, d}
          <rect
            x={w * BOX_SIZE}
            y={d * BOX_SIZE}
            width={BOX_SIZE}
            height={BOX_SIZE}
            fill={getColor(count, max)}
          />
        {/each}
      {/each}
    </svg>
  {/each}
</a>

<style>
  .contrib-container {
    display: flex;
    > * {
      flex: 0 0 1500px;
    }
    -webkit-mask-image: linear-gradient(
      to right,
      transparent 0%,
      black 10%,
      black 90%,
      transparent 100%
    );
    mask-image: linear-gradient(
      to right,
      transparent 0%,
      black 10%,
      black 90%,
      transparent 100%
    );
  }

  @keyframes scrolling {
    0% {
      transform: translateX(0);
    }
    100% {
      transform: translateX(-100%);
    }
  }

  svg {
    display: flex;
    will-change: transform;
    animation: scrolling 15s linear infinite;
  }
</style>
