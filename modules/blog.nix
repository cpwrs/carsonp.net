{config, ...}: {
  age.secrets."blog-env".file = ./../secrets/blog-env.age;

  blog = {
    enable = true;
    port = 8000;
    secretEnv = config.age.secrets."blog-env".path;
  };
}
