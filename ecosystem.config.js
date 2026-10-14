module.exports = {
  apps: [
    {
      name: 'opencode-server',
      script: 'start-opencode-server.bat',
      interpreter: 'cmd.exe',
      cwd: 'D:\\Projects\\TrastornadoresApp',
      env: {
        NODE_ENV: 'development'
      },
      max_memory_restart: '500M',
      restart_delay: 5000,
      autorestart: true,
      watch: false
    },
    {
      name: 'trastornadores-cycles',
      script: 'start-cycles.bat',
      interpreter: 'cmd.exe',
      cwd: 'D:\\Projects\\TrastornadoresApp',
      env: {
        NODE_ENV: 'development'
      },
      max_memory_restart: '300M',
      restart_delay: 10000,
      autorestart: true,
      watch: false
    }
  ]
};