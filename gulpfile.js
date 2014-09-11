
// Require

var gulp       = require('gulp'),
    gutil      = require('gulp-util'),
    browserify = require('browserify'),
    connect    = require('gulp-connect'),
    source     = require('vinyl-source-stream');


// Helpers

function reload (files) {
  gulp.src(files.path).pipe(connect.reload());
}

function handle (error) {
  gutil.log(gutil.colors.red('Error:'), error.message); //toString());
  this.emit('end');
}


// Preconfigure bundler
var bundler = browserify({
  debug: true,
  cache: {},
  packageCache: {},
  fullPaths: true,
  entries: [ './src/index.ls' ],
  extensions: '.ls'
});


// Tasks

gulp.task('server', function () {
  connect.server({
    root: 'public',
    livereload: true
  });
});

gulp.task('browserify', function () {
  return bundler
    .bundle()
    .on('error', handle)
    .pipe(source('app.js'))
    .pipe(gulp.dest('public'))
});


// Register

gulp.task('default', [ 'server', 'browserify' ], function () {
  gulp.watch(['src/**/*.ls'], [ 'browserify' ]);
  gulp.watch(['public/**/*']).on('change', reload);
});

