NumUtil = require('../../../../utils/NumUtil');
add = require('vectors/add')(2)
sub = require('vectors/sub')(2)
normalize = require('vectors/normalize')(2)
mult = require('vectors/mult')(2)
mag = require('vectors/mag')(2)

class BasicShape

    id          : null

    _scene      : null

    g           : null
    stage       : null
    ctx         : null
    size        : null
    mass        : 1
    palette     : null
    color       : null
    config      : null

    #behavior
    pos         : null
    vel         : null
    velRot      : null
    toX         : 0
    toY         : 0
    distanceToTargetMax : 0
    speedScale : 0

    behavior : 'target'
    target      : null
    targetMass  : 10000

    spring      : .007
    friction    : .8
    targetAngle : 0
    targetAngleStep : 0
    attractionRadius: 0

    canOrbit    : false


    constructor : (@config, size, scene, alpha) ->
        @id = String.fromCharCode(65 + Math.floor(Math.random() * 26)) + Date.now()

        # console.log size, scene

        @_scene = scene

        @spring = NumUtil.map( size, 20, 60, .007, .007 )
        @targetAngle = Math.random() * Math.PI * 2
        @targetAngleStep = NumUtil.map( size, 20, 60, .08, .04 ) * Math.random()
        @attractionRadius = NumUtil.map( size, 30, 60, 170, 155 )
        # @attractionRadius = 200


        @w = size
        @h = size
        @mass = size 
        @acc = Math.random()
        # config =
            # category : null
            # object_id : null
            # object_name: null
            # icon: null
            # data_type: null
            # value_type: null
            # video: null
            # image: null
            # copy_en: null
            # copy_cat: null

        @sprite = new PIXI.Sprite()
        @sprite.alpha = alpha || 1

        @g = new PIXI.Graphics()
        @g.beginFill @color
        
        @sprite.addChild @g

        @init()

        
        # @sprite.rotation = NumUtil.toRadians _.random(360)

        # @vel =
        #     x: .5 * (( Math.random() * 2 ) - 1)
        #     y: .5 * (( Math.random() * 2 ) - 1)

        @setBehaviorProps()

        @bindEvents()

        @pos = [ 0, 0 ]
        @vel = [ .5 * (( Math.random() * 2 ) - 1), .5 * (( Math.random() * 2 ) - 1) ]
        @target = [ window.innerWidth / 2, window.innerHeight / 2 ]

        null


    init : =>
        console.log 'override this'


    bindEvents : ->
        @sprite.interactive = true

        @sprite.mousedown = @onMouseDown
        @sprite.mouseup = @onMouseUp

        null


    update: ( dt, time ) ->
        # -----------------
        # Basic behavior, apply constant force
        # -----------------
        if @behavior == 'basic'
            @applyForce @vel
            
            # behavior on bounds
            if ( @pos[0] > @_scene.width )
                @vel[0] *= -1
            else if ( @pos[0] < 0 )
                @vel[0] *= -1

            if ( @pos[1] > @_scene.height )
                @vel[1] *= -1
            else if ( @pos[1] < 0 )
                @vel[1] *= -1

            @sprite.position.x = @pos[0]
            @sprite.position.y = @pos[1]

        # -----------------
        # vibrate behavior
        # -----------------
        else if @behavior == 'vibrate'
            randVelX = (( Math.random() * ( @vel.x * 2 ) ) - @vel.x )
            randVelY = (( Math.random() * ( @vel.y * 2 ) ) - @vel.y )
            @sprite.x += randVelX
            @sprite.y += randVelY

        # -----------------
        # go to location behavior
        # -----------------
        else if @behavior == 'target'
            distanceToTarget = NumUtil.distanceBetweenPoints( {x: @toX, y: @toY}, {x: @sprite.x, y: @sprite.y} )

            if distanceToTarget < @distanceToTargetMax
                @setBehaviorProps()

            @sprite.position.x += @speedScale * ( @toX - @sprite.position.x) * .005 
            @sprite.position.y += @speedScale * ( @toY - @sprite.position.y) * .005 

            @pos[0] = @sprite.position.x
            @pos[1] = @sprite.position.y

        # -----------------
        # go to location behavior
        # -----------------
        else if @behavior == 'attraction'
            @applyAttractionForce()
            @sprite.position.x = @pos[0]
            @sprite.position.y = @pos[1]
        

        @sprite.rotation += @velRot

        null

    setBehaviorProps: ->
        @distanceToTargetMax = 10 + Math.floor Math.random() * 50
        @speedScale = Math.random() * 2
        if @speedScale < .3 then @speedScale += Math.random() * .7
        @toX = (Math.floor Math.random() * window.innerWidth) #/ window.devicePixelRatio;
        @toY = (Math.floor Math.random() * window.innerHeight) #/ window.devicePixelRatio;

        @velRot = .01 * (( Math.random() * 2 ) - 1)

        null

    applyForce: ( vec ) ->
        add( @pos, vec )

        

        null


    applyAttractionForce: ->
        # force = sub( @target , @pos );
        # distance = mag( force )
        # Remember, we need to constrain the distance so that our circle doesn’t spin out of control.
        # distance[0] = Math.max(5, Math.min(distance[0], 25));
        # distance[1] = Math.max(5, Math.min(distance[1], 25));
        # console.log distance
        
        # console.log @target

        # normalize( force )
        # strength = (G * mass * m.mass) / (distance * distance);
        # strength = ( 10000 * @mass ) / ( distance * distance );
        # mult( force, strength )

        # console.log force

        @targetAngle += @targetAngleStep
        if @targetAngle >= Math.PI * 2 then @targetAngle = 0

        distanceToTarget = NumUtil.distanceBetweenPoints( {x: @targetX, y: @targetY}, {x: @sprite.x, y: @sprite.y} )
        # if distanceToTarget < 20 then @targetAngle += Math.random() * Math.PI * 2

        @targetX = ( window.innerWidth / 2 ) + @attractionRadius * Math.cos( @targetAngle )
        @targetY = ( window.innerHeight / 2 ) + @attractionRadius * Math.sin( @targetAngle )

        dx = @targetX - @pos[0]
        dy = @targetY - @pos[1]
        ax = dx * @spring
        ay = dy * @spring

        @vel[0] += ax
        @vel[1] += ay
        @vel[0] *= @friction;
        @vel[1] *= @friction;
        
        @pos[0] += @vel[0]
        @pos[1] += @vel[1]

    move : ( x, y ) =>
        @pos[0] = x
        @pos[1] = y 

        @sprite.position.x = @pos[0]
        @sprite.position.y = @pos[1]
        null

    moveX: ( x ) ->
        @pos[0] = x

        # @sprite.position.x = @pos.x

        null


    moveY: ( y ) ->
        @pos[1] = y
        
        # @sprite.position.y = @pos.y

        null

    width  : => return @w
    height : => return @h
    radius : => return @w / 2

    onMouseDown: => 
        console.warn 'BasicShape::onMouseDown should be overrided'

        null

    onMouseUp: => 
        if @canOrbit
            @behavior = 'attraction'
        else 
            @bounceScale()

        null


    fadeTo: ( alpha, delay = 0 ) ->
        TweenMax.to( @sprite, .3, { alpha: alpha, delay: delay } )

        null


    bounceScale: ->
        @sprite.scale.x = @sprite.scale.y = @sprite.scale.x * 1.5
        TweenMax.to( @sprite.scale, .8, { x: 1, y: 1, delay: .1, ease: Elastic.easeOut } )

      null

module.exports = BasicShape
