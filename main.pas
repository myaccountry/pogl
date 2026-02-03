program main;

uses
	GL, Glut, Unix, primitives;


const
	WIDTH = 800;
	HEIGHT = 600;

	ROTATE_AUTO = true;

var
	WindowWidth: LongInt = WIDTH;
	WindowHeight: LongInt = HEIGHT;
	isInitialized: Boolean = false;
	OBJ_FILE_NAME: string = 'none';	

	angl: Angles;
	addAngl: Angles;
	
	p1, p2, pc: Point;
	linegl: Line;
	cuber: Primitive;



procedure Initialize;
begin
	glClearColor(0.0, 0.0, 0.0, 0.0); 
end;
procedure Display; cdecl;
begin
	glClear(GL_COLOR_BUFFER_BIT);

	if not isInitialized then
	begin
		ParseObjFile(ParamStr(1), cuber);
		InitAngles(angl, 0.0, 0.0, 0.0); 
		InitPoint(p1, -40, 0, 0);
		InitPoint(p2, 40, 0, 0);
		InitPoint(pc, 20, 20, 0);
		InitLine(linegl, p1, p2);
		isInitialized := true;
	end;

	if ROTATE_AUTO then
		AddRotation(angl, addAngl);
	//AddRotation(angl, 3.5, 5.0, 5.5);

	//RotateLine(linegl, linegl.pointCenter, angl);
	//DrawLine(linegl);

	RotatePrimitive(cuber, pc, angl);
	DrawPrimitive(cuber);
	
	glutSwapBuffers;
	glutPostRedisplay;
end;

procedure Keyboard(key: Byte; x, y: LongInt); cdecl;
begin
	if key = 27 then // ESC key
		halt(0);
end;

procedure SpecialKeys(key: LongInt; x, y: LongInt); cdecl;
const
	STEP = 0.5; 
begin
	case key of
		GLUT_KEY_LEFT: 
			InitAngles(addAngl, 0.0, STEP, 0.0);
		GLUT_KEY_RIGHT: 
			InitAngles(addAngl, 0.0, -STEP, 0.0);
		GLUT_KEY_UP:    
			InitAngles(addAngl, STEP, 0.0, 0.0);
		GLUT_KEY_DOWN: 
			InitAngles(addAngl, -STEP, 0.0, 0.0);
		GLUT_KEY_PAGE_UP: 
			InitAngles(addAngl, 0.0, 0.0, STEP);
		GLUT_KEY_PAGE_DOWN: 
			InitAngles(addAngl, 0.0, 0.0, -STEP);
		GLUT_KEY_HOME:  
			InitAngles(addAngl, 0.0, 0.0, 0.0);
	end;
	
	if not ROTATE_AUTO then
		AddRotation(angl, addAngl);
	
	//RotateLine(linegl, linegl.pointCenter, angl);
	//DrawLine(linegl);

	RotatePrimitive(cuber, pc, angl);
	DrawPrimitive(cuber);
	
	glutSwapBuffers;
	glutPostRedisplay;
end;

procedure PrintHelp();
begin
	writeln('This is the POGL render. Usage:');
	writeln(); write('    ');
	writeln('pogl [file] [xyz-k] [glob-k] [point-size]');
	writeln(); writeln();
	
	writeln('Description of pogl arguments');
	writeln(); write('    ');
	writeln('[file] - Name of Wavefron obj file. Other format is invalid');
	writeln(); write('    ');
	writeln('[xyz-k] - Coefficient of XYZ coords. Big K = Big Quality');
	writeln(); write('    ');
	writeln('[glob-k] - Coefficient of Space Area. Big K = Big Visibility');
	writeln(); write('    ');
	writeln('[point-size] - Size of the "brush"');
	writeln(); writeln();

	writeln('Program GUI usage');
	writeln(); write('    ');
	writeln('Arrow, PageUp, PageDown keys - rotate Object');
	writeln(); write('        ');
	writeln('LeftArrow - Rotate anticlockwise around Y-axis');
	writeln(); write('        ');
	writeln('RightArrow - Rotate clockwise around Y-axis');
	writeln(); write('        ');
	writeln('DownArrow - Rotate anticlockwise around X-axis');
	writeln(); write('        ');
	writeln('UpArrow - Rotate clockwise around X-axis');
	writeln(); write('        ');
	writeln('PageUp - Rotate anticlockwise around Z-axis');
	writeln(); write('        ');
	writeln('PageDown - Rotate clockwise around Z-axis');
	writeln(); write('    ');
	writeln('Home key - Stop rotating object');
	writeln(); write('    ');
	writeln('Esc key - Exit from programm');
	writeln(); writeln();

	writeln('All about this programm write to <eqorrannev@gmail.com>');
	writeln('                                 <https://t.me/grannev>');
end;

begin

	OBJ_FILE_NAME := ParamStr(1);

	if (OBJ_FILE_NAME = '--help') or (OBJ_FILE_NAME = '-h') then begin
		PrintHelp();
		exit();
	end;

	Val(ParamStr(2), XYZ_K_FROM_ARG);	
	Val(ParamStr(3), GLOB_K_FROM_ARG);
	Val(ParamStr(4), STD_POINT_SIZE_FROM_ARG);

	glutInit(@argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB);
	glutInitWindowSize(WindowWidth, WindowHeight);
	glutCreateWindow('PascalGraphics');
	Initialize;

	glutDisplayFunc(@Display);
	glutKeyboardFunc(@Keyboard);
	glutSpecialFunc(@SpecialKeys); 

	glutMainLoop;
end.
