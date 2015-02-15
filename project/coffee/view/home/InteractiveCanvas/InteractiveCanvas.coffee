AbstractView    = require '../../AbstractView'
Scene           = require('./Scene.coffee');
Circle          = require './shapes/Circle'
Triangle        = require './shapes/Triangle'
Square          = require('./shapes/Square.coffee');
NumUtil         = require('../../../utils/NumUtil.coffee');
 
class InteractiveCanvas extends AbstractView

    template : 'interactive-element'
    shapes   : null

    linesObj: null
    linesAlphaScale: 0

    scene: null

    deltaTime: 0
    lastTime: Date.now()


    init : =>

        PIXI.dontSayHello = true
        @w = window.innerWidth / window.devicePixelRatio
        @h = window.innerHeight / window.devicePixelRatio

        @scene = new Scene({
            container: @$el[0]
        })

        @shapes = []

        @bindEvents()
        @addShapes()
        @update()
        null

    addShapes : =>

        objs =
            "circle"   : Circle
            "triangle" : Triangle
            "square"   : Square

        @B().objects.each (data) =>
            size = _.random(10, 60)
            object = new objs[data.get('data_type').toLowerCase()](data, size, @scene)
            object.move _.random(@w), _.random(@h)
            @shapes.push( object )
            @scene.addChild object.sprite


        middle = new Circle null, 120, @scene
        middle.move @w/2, @h/2
        @scene.addChild middle.sprite
        middle.animate()


        null

    update : =>
        @deltaTime = Date.now() - @lastTime
        @lastTime = Date.now()

        # @updateLines()

        for shape in @shapes
            shape.update()

            # behavior on bounds
            # if ( shape.sprite.x > @w + shape.w )
            #     shape.sprite.x = 0 - shape.w
            #     shape.sprite.y = Math.random() * @h
            # else if ( shape.sprite.x < 0 - shape.w )
            #     shape.sprite.x = @w + shape.w
            #     shape.sprite.y = Math.random() * @h

            # if ( shape.sprite.y > @h + shape.h )
            #     shape.sprite.y = 0 - shape.h
            #     shape.sprite.x = Math.random() * @w
            # else if ( shape.sprite.y < 0 - shape.h )
            #     shape.sprite.y = @h + shape.h
            #     shape.sprite.x = Math.random() * @w

        
        @render()

        requestAnimFrame @update
        null

    addLines: =>
        @linesObj = new PIXI.Graphics()
        

        @scene.addChild @linesObj

        null

    updateLines: ->
        @linesObj.clear()

        for shape in @shapes
            dist = NumUtil.distanceBetweenPoints shape.sprite.position, { x: @w/2, y: @h/2 }

            # @linesObj.lineStyle( 1, "#rgba(0, 0, 0, {NumUtil.map dist, 0, 300, 1, .1 )})" )
            @linesObj.lineStyle( .5, 0x000000, NumUtil.map(dist, 0, 300, 1, .1) )
            @linesObj.moveTo(@w/2, @h/2);
            @linesObj.lineTo( shape.sprite.x , shape.sprite.y);
         
        null

    render : =>
        @scene.render()

        null

    bindEvents : =>
        #temporary
        window.addEventListener('keyup', @onKeyup)

        @B().appView.on @B().appView.EVENT_UPDATE_DIMENSIONS, @setDims

        # @$window.on 'resize orientationchange', @onResize

        null

    setDims : (renderer=false)=>
        return unless @renderer
        @w = window.innerWidth / window.devicePixelRatio
        @h = window.innerHeight / window.devicePixelRatio

        @$el.css
            'max-height' : @h
            'overflow' : 'hidden'

        @renderer.resize @w, @h
        null


    onResize: () =>
        console.log @
        null


    onKeyup: ( evt ) =>
        if evt.keyCode != 32 then return

        null

module.exports = InteractiveCanvas