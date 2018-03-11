
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.math.RandGenerator;
import hxDaedalus.data.math.Tools;
import hxDaedalus.data.math.Triangle;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.SimpleView;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

class Main extends Sprite
{
  
  var mesh : Mesh;
  var view : SimpleView;
  var meshView: SimpleView;
  
  var entityAI : EntityAI;
  var pathfinder : PathFinder;
  var path : Array<Float>;
  var pathSampler : LinearPathSampler;
  
  var newPath:Bool = false;
  
  var objects:Array<Object> = [];
  
  
  public static function main():Void {
    Lib.current.addChild(new Main());
  }
  
  public function new(){
    super();
    // build a rectangular mesh
    mesh = RectMesh.buildRectangle(1000, 1000);
    
    Lib.current.addChild(this);
    
    // create a viewport
    var viewSprite = new Sprite();
    view = new SimpleView(viewSprite.graphics);
    addChild(viewSprite);
    
    meshView = new SimpleView(this.graphics);
    
    // pseudo random generator
    var randGen : RandGenerator;
    randGen = new RandGenerator();
    randGen.seed = 7259;  // put a 4 digits number here  
    
    /*
    // populate mesh with many square objects
    var object : Object;
    var shapeCoords : Array<Float>;
    for (i in 0...50){
      object = new Object();
      shapeCoords = new Array<Float>();
      shapeCoords = [ -1, -1, 1, -1,
               1, -1, 1, 1,
              1, 1, -1, 1,
              -1, 1, -1, -1];
      object.coordinates = shapeCoords;
      randGen.rangeMin = 10;
      randGen.rangeMax = 40;
      object.scaleX = randGen.next();
      object.scaleY = randGen.next();
      randGen.rangeMin = 0;
      randGen.rangeMax = 1000;
      object.rotation = (randGen.next() / 1000) * Math.PI / 2;
      randGen.rangeMin = 50;
      randGen.rangeMax = 600;
      object.x = randGen.next();
      object.y = randGen.next();
      _mesh.insertObject(object);
    } 
    */
    
    // show result mesh on screen
    var shape = [ 93., 195., 129., 92., 280., 81., 402., 134., 477., 70., 619., 61.,759., 97., 758., 247., 662., 347., 665., 230., 721., 140., 607., 117., 472., 171., 580., 178., 603., 257., 605., 377., 690., 404., 787., 328., 786., 480., 617., 510., 611., 439., 544., 400., 529., 291., 509., 218., 400., 358., 489., 402., 425., 479., 268., 464., 341., 338., 393., 427., 373., 284., 429., 197., 301., 150., 296., 245., 252., 384., 118., 360., 190., 272., 244., 165., 81., 259., 40., 216.];
    shape = [55,55,145,55,235,100,325,55,415,55,415,145,370,235,415,320,415,410,325,410,235,365,145,410,55,410,55,320,105,235,55,145];
    var shape2: Array<Float> = [115,235,235,355,360,235,235,110];

    for (i in 0...3) {
      var object = new Object();
      object.multiPoints = [shape, shape2];
      object.scaleX = 1;
      object.scaleY = 1;
      objects.push(object);
      mesh.insertObject(object);
    }
    
    objects[1].x = objects[1].y = 200;
    objects[2].x = objects[2].y = 500;
    
    mesh.updateObjects();
    
    
    meshView.drawMesh(mesh);
    
    
    // we need an entity
    entityAI = new EntityAI();
    // set radius as size for your entity
    entityAI.radius = 4;
    // set a position
    entityAI.x = 20;
    entityAI.y = 20;
    
    // show entity on screen
    view.drawEntity(entityAI);
    
    // now configure the pathfinder
    pathfinder = new PathFinder();
    pathfinder.entity = entityAI;  // set the entity  
    pathfinder.mesh = mesh;  // set the mesh  
    
    // we need a vector to store the path
    path = new Array<Float>();
    
    // then configure the path sampler
    pathSampler = new LinearPathSampler();
    pathSampler.entity = entityAI;
    pathSampler.samplingDistance = 10;
    pathSampler.path = path;
    
    // click/drag
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
    Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
    
    // animate
    Lib.current.stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
    
    // key presses
    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
    
    var fps = new openfl.display.FPS();
    //Lib.current.stage.addChild(fps);
  }
  
  function _onMouseUp( event: MouseEvent ): Void {
    newPath = false;
  }
  
  function _onMouseDown( event: MouseEvent ): Void {
    newPath = true;
  }
  
  
  function drawObject(view:SimpleView, o: Object, color: Int, alpha: Float ){
    var triangles = new Array<Triangle>();
    Tools.extractObjectTriangles( o, triangles );
    
    for ( tri in triangles ) {
      view.graphics.beginFill(color, alpha);
      view.graphics.drawTri( [tri.a.x, tri.a.y, tri.b.x, tri.b.y, tri.c.x, tri.c.y] );
      view.graphics.endFill();
    }
  }

  var angle = 0.;
  function _onEnterFrame( event: Event ): Void {
    
    objects[1].x = 200 + 100 * Math.sin( angle );
    angle += 0.08;
    objects[1].y = 200 + 100 * Math.cos( angle );
    
    mesh.updateObjects();  // don't forget to update
    pathfinder.mesh = mesh;  // set the mesh

    meshView.drawMesh(mesh, true);
    for (o in objects) drawObject(meshView, o, 0xFFFF00, 1);
    
    if ( newPath ) {
      view.graphics.clear();
      
      // find path !
      pathfinder.findPath( stage.mouseX, stage.mouseY, path );
      
      // show path on screen
      view.drawPath( path );
      
      // reset the path sampler to manage new generated path
      pathSampler.reset();
      
      // show entity position on screen
      view.drawEntity(entityAI);
    }
    
    // animate !
    if ( pathSampler.hasNext ) {
      // move entity
      pathSampler.next();      
      
      // show entity position on screen
      view.drawEntity(entityAI);
    }
  }
  
  function _onKeyDown( event:KeyboardEvent ): Void {
    if( event.keyCode == 27 ) {  // ESC
    #if flash
      flash.system.System.exit(1);
    #elseif sys
      Sys.exit(1);
    #end
    }
  }
}
