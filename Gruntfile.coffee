module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      options:
        sourceMap: true
      compile:
        files: [
          expand: true
          cwd: './src/'
          src: ['*.litcoffee', '*.coffee']
          dest: '.'
          ext: '.js'
        ]
      tests:
        files: [
          expand: true
          src: 'tests/*.coffee'
          ext: '.js'
        ]
    connect:
      server:
        options:
          base: '.'
          port: 9001
    watch:
      options:
        atBegin: true
        livereload: true
      coffee:
        files: ['src/*.litcoffee', 'src/*.coffee', 'tests/*.coffee']
        tasks: ['coffee']
    bump:
      options:
        files: ['package.json', 'bower.json']
        commit: true
        commitFiles: ['-a']
        createTag: true
        push: false
    karma:
      unit:
        configFile: 'karma.config.js'
        singleRun: true

  # Load grunt plugins
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-karma'

  # Define tasks.
  grunt.registerTask 'serve', ['connect:server', 'watch']
  grunt.registerTask 'build', ['coffee']
  grunt.registerTask 'test', ['coffee:compile', 'coffee:tests', 'karma']
  grunt.registerTask 'version:patch', ['build', 'bump:patch']
  grunt.registerTask 'version:minor', ['build', 'bump:minor']
  grunt.registerTask 'version:major', ['build', 'bump:major']
