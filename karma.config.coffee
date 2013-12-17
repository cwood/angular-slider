
module.exports = (config) ->
  config.set

    basePath: '.'
    frameworks: ['jasmine']
    preprocessors :
      'angular-slider.js': 'coverage',
      'angular-slider-contrib.js': 'coverage',
    files: [
      'bower_components/jquery/jquery.js',
      'bower_components/underscore/underscore.js',
      'bower_components/angular/angular.js',
      'bower_components/angular-touch/angular-touch.js',
      'bower_components/angular-mocks/angular-mocks.js',
      'angular-slider.js',
      'angular-slider-contrib.js',
      'tests/*.js'
    ]
    reporters: ['progress', 'coverage']
    converageReporter:
      type: 'html',
      dir: 'coverage/'
    port: 9876
    colors: true
    logLevel: config.LOG_INFO
    autoWatch: true
    captureTimeout: 60000
    singleRun: false
