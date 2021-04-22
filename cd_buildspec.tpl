version: 0.2
env:
  shell: ${cd_shell}
phases:
  install:
    commands:
      - ${install_commands}
  pre_build:
    commands:
      - ${pre_build_commands}
  build:
    commands:
      - ${build_commands}
  post_build:
    commands:
      - ${post_build_commands}
