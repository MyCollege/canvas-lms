module.exports = function (grunt) {
  grunt.initConfig({
    watch: {
      build: {
        files: ['index.js', 'lib/*.js'],
        tasks: ['build']
      }
    },

    browserify: {
      build: {
        src: ['index.js'],
        dest: 'dist/color-slicer.js',
        options: {
          standalone: 'colorSlicer'
        }
      }
    },

    nodeunit: {
      tests: ['test/*_test.js']
    },

    jshint: {
      src: [
        'lib/**/*.js',
        'test/**/*.js',
      ]
    }
  });

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('test', ['jshint', 'nodeunit']);
  grunt.registerTask('build', ['browserify']);
  grunt.registerTask('default', ['build', 'watch']);
};
