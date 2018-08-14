// plugin
Matter.use('matter-wrap');

let floatyBubbles = {
    // customizable options (passed into init function)
    options: {
        canvasSelector: '', // to find <canvas> in DOM to draw on
        radiusRange: [15, 75], // random range of body radii
        xVarianceRange: [-0.75, 0.75], // random range of x velocity scaling on bodies
        yVarianceRange: [0.75, 1.5], // random range of y velocity scaling on bodies
        airFriction: 0.01, // air friction of bodies
        opacity: 1, // opacity of bodies
        collisions: true, // do bodies collide or pass through
        scrollVelocity: 0.0125, // scaling of scroll delta to velocity applied to bodies
        pixelsPerBody: 100000, // viewport pixels required for each body added

        // colors to cycle through to fill bodies
        colors: ['#E3EB9D', '#FFFAC9', '#F7A26C']
    },

    // throttling intervals (in ms)
    scrollDelay: 0,
    resizeDelay: 0,

    // throttling variables and timeouts
    lastOffset: undefined,
    scrollTimeout: undefined,
    resizeTimeout: undefined,

    // Matter.js objects
    engine: undefined,
    render: undefined,
    runner: undefined,
    bodies: undefined,

    // kicks things off
    init(options) {
        // override default options with incoming options
        this.options = Object.assign({}, this.options, options);

        let viewportWidth = document.documentElement.clientWidth;
        let viewportHeight = document.documentElement.clientHeight;

        this.lastOffset = window.pageYOffset;
        this.scrollTimeout = null;
        this.resizeTimeout = null;

        // engine
        this.engine = Matter.Engine.create();
        this.engine.world.gravity.y = 0.7;

        // render
        this.render = Matter.Render.create({
            canvas: document.querySelector(this.options.canvasSelector),
            engine: this.engine,
            options: {
                width: viewportWidth,
                height: viewportHeight,
                wireframes: false,
                background: 'transparent'
            }
        });
        Matter.Render.run(this.render);

        // runner
        this.runner = Matter.Runner.create();
        Matter.Runner.run(this.runner, this.engine);

        // bodies
        this.bodies = [];
        let totalBodies = Math.round(viewportWidth * viewportHeight / this.options.pixelsPerBody);
        for (let i = 0; i <= totalBodies; i++) {
            let body = this.createBody(viewportWidth, viewportHeight);
            this.bodies.push(body);
        }
        Matter.World.add(this.engine.world, this.bodies);

        // events
        window.addEventListener('scroll', this.onScrollThrottled.bind(this));
        window.addEventListener('resize', this.onResizeThrottled.bind(this));
    },

    // stop all the things
    shutdown() {
        Matter.Engine.clear(this.engine);
        Matter.Render.stop(this.render);
        Matter.Runner.stop(this.runner);

        window.removeEventListener('scroll', this.onScrollThrottled);
        window.removeEventListener('resize', this.onResizeThrottled);
    },

    // random number generator
    randomize(range) {
        let [min, max] = range;
        return Math.random() * (max - min) + min;
    },

    // create body with some random parameters
    createBody(viewportWidth, viewportHeight) {
        let x = this.randomize([0, viewportWidth]);
        let y = this.randomize([0, viewportHeight]);
        let radius = this.randomize(this.options.radiusRange);
        let color = this.options.colors[this.bodies.length % this.options.colors.length];

        return Matter.Bodies.circle(x, y, radius, {
            render: {
                fillStyle: color,
                opacity: this.options.opacity
            },
            frictionAir: this.options.airFriction,
            collisionFilter: {
                group: this.options.collisions ? 1 : -1
            },
            plugin: {
                wrap: {
                    min: { x: 0, y: 0 },
                    max: { x: viewportWidth, y: viewportHeight }
                }
            }
        });
    },

    // enforces throttling of scroll handler
    onScrollThrottled() {
        if (!this.scrollTimeout) {
            this.scrollTimeout = setTimeout(this.onScroll.bind(this), this.scrollDelay);
        }
    },

    // applies velocity to bodies based on scrolling with some randomness
    onScroll() {
        this.scrollTimeout = null;

        let delta = (this.lastOffset - window.pageYOffset) * this.options.scrollVelocity;
        this.bodies.forEach((body) => {
            Matter.Body.setVelocity(body, {
                x: body.velocity.x + delta * this.randomize(this.options.xVarianceRange),
                y: body.velocity.y + delta * this.randomize(this.options.yVarianceRange)
            });
        });

        this.lastOffset = window.pageYOffset;
    },

    // enforces throttling of resize handler
    onResizeThrottled() {
        if (!this.resizeTimeout) {
            this.resizeTimeout = setTimeout(this.onResize.bind(this), this.resizeDelay);
        }
    },

    // restart everything with the new viewport size
    onResize() {
        this.shutdown();
        this.init();
    }
};

// wait for DOM to load
window.addEventListener('DOMContentLoaded', () => {
    // start floaty bubbles background
    Object.create(floatyBubbles).init({
        canvasSelector: '#bg'
    });
});