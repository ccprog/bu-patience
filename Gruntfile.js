const exec = require('child_process').exec;
const execSync = require('child_process').execSync;
const basename = require('path').basename;
var CoffeeScript = require('coffeescript');

module.exports = function(grunt) {
    const list = ['back', 'empty'];
    for (const val of [1,2,3,4,5,6,7,8,9,10,'jack','queen','king']) {
        for (const suit of ["club", "diamond", "heart", "spade"]) {
            list.push(`${val}_${suit}`);
        }
    }

    const cards = {};

    function encode (fn, callback) {
        exec('base64 -w0 ' + fn, (error, stdout, stderr) => {
            if (error)  return callback(error);
    
            let id = basename(fn, '.png');
            id = id.replace('jack', '11');
            id = id.replace('queen', '12');
            id = id.replace('king', '13');
            grunt.log.writeln('Encoding card ' + id);
            cards[id] = 'data:image/png;base64,' + stdout;
    
            if (Object.keys(cards).length === 54) {
                grunt.log.write('exporting to JSON...');
                grunt.file.write('web/cards.json', JSON.stringify(cards));
                execSync('rm -r temp/');
                grunt.log.writeln('Done');
            }
            return callback(null);
        });
    }
    
    grunt.initConfig({
        svg_icon_toolbox: {
            src: 'src/cards.svg',
            options: {
            tasks: [
                { task: 'export', arg: {
                    ids: list,
                    format: 'png',
                    dir: 'temp/',
                    exportOptions: { width: 200 },
                    postProcess: encode
                } }
            ]
            }
        },
        to_json: { default: {
            expand: true,
            cwd: 'src/rulesets/',
            src: '*.coffee',
            filter: (file) => !file.includes('_NOTREADY_'),
            dest: 'web/rulesets/',
            ext: '.json'
        } },
        coffee: {
            options: { bare: true },
            validator: {
                files: {
                    'tests/val.js': 'tests/val.coffee'
                }
            },
            main: {
                files: {
                    'web/patience.js': [
                        'LICENCE',
                        'src/patience_pile.coffee',
                        'src/patience_factory.coffee',
                        'src/patience_game.coffee',
                        'src/patience_area.coffee' ]
                }
            }
        }
    });

    grunt.task.loadNpmTasks('svg-icon-toolbox');

    grunt.task.registerTask('cards_version', function () {
        const fn = 'web/cards_version';
        const version = parseInt(grunt.file.read(fn), 10);
        grunt.file.write(fn, version + 1);
    })
    grunt.task.registerTask('cards', ['svg_icon_toolbox', 'cards_version']);

    grunt.registerTask('splitter', 'process rulefactory', function () {
        const source = grunt.file.read('src/rulefactory.coffee');

        const rx_schema = /# output-start validate\n([^]+?)# output-end validate/g;
        let schema = "";
        while (true) {
            const res = rx_schema.exec(source);
            if (!res)  break;
            schema += res[1];
        }

        const script = CoffeeScript.compile(schema, { bare: true });
        eval(script);
        for (let name in exports) {
            const json = JSON.stringify(exports[name], null, 2);
            grunt.file.write("src/rulesets/" + name, json);
        }
        
        const rx_factory = /# output-start rulefactory\n([^]+?)# output-end rulefactory/g;
        let factory = "";
        while (true) {
            const res = rx_factory.exec(source);
            if (!res) break;
            factory += res[1];
        }
        
        grunt.file.write("src/patience_factory.coffee", factory);
    });

    grunt.registerMultiTask('rulesets', 'process rulesets', function () {
        this.files.forEach((file) => {
            const source = grunt.file.read(file.src[0]);
            const script = CoffeeScript.compile(source, { bare: true });
            eval(script);
            const json = JSON.stringify(ruleset);
            grunt.file.write(file.dest, json);
        });
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');

    grunt.registerTask('clean', function () {
        this.requires(['splitter']);
        execSync('rm -r src/patience_factory.coffee');
    });

    grunt.registerTask('compile', ['splitter', 'coffee:main', 'clean']);
};