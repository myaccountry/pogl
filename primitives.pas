unit primitives;


interface

uses
	GL, Glut, Unix, SysUtils;


const
	PI = 3.14;
	FULL_ANGLE = 360.0;
	SEMI_ANGLE = 180.0;
	RAD_TO_DEG = 180.0 / pi;
	DEG_TO_RAD = pi / 180.0;

	XYZ_K = 50.0;
	GLOB_K = 300.0;
	STD_POINT_SIZE = 1;


var
	XYZ_K_FROM_ARG : double = XYZ_K;
	GLOB_K_FROM_ARG : double = GLOB_K;
	STD_POINT_SIZE_FROM_ARG : double = STD_POINT_SIZE;


type
	StringArray = array of string;

	Angles = record
		x, y, z: double;
	end;

	Graph = record
		i, j: integer;
	end;
	
	Point = record
		x, y, z: double;
		angle: Angles;
		oldX, oldY, oldZ: double;
	end;

	Line = record
		vertexA, vertexB: Point;
		pointCenter: Point;
		angle: Angles;
		length: double;
	end;

	Primitive = record
		vertex: array of Point;
		graphs: array of Graph;
		pointCenter: point;
		angles: Angles;
	end;


procedure InitAngles(var angleIn: Angles; x, y, z: double);
procedure AddRotation(var first: Angles; second: Angles);
procedure AddRotation(var first: Angles; x, y, z: double);

procedure InitGraph(var graphIn: Graph; i, j: integer);

procedure InitPoint(var pointIn: Point; x, y, z: double);
procedure UpdatePointXYZ(var pointIn: Point; x, y, z: double);
procedure RotatePoint(var pointIn: Point; pointCenter: Point; angleIn: Angles);
procedure DrawPoint(PointIn: point);

procedure InitLine(var lineIn: Line; vertexA, vertexB: point);
procedure RotateLine(var lineIn: line; pointCenter: point; angleIn: Angles);
procedure DrawLine(lineIn: Line);


procedure ParseObjFile(name: string; var PrimIn: Primitive);
procedure RotatePrimitive(var PrimIn: Primitive; pointCenter: Point; angleIn: Angles);
procedure DrawPrimitive(var PrimIn: Primitive);



implementation

procedure InitAngles(var angleIn: Angles; x, y, z: double);
begin
	angleIn.x := x;
	angleIn.y := y;
	angleIn.z := z;
end;

procedure AddRotation(var first: Angles; second: Angles);
begin
	first.x := first.x + second.x;
	first.y := first.y + second.y;
	first.z := first.z + second.z;
end;

procedure AddRotation(var first: Angles; x, y, z: double);
begin
	first.x := first.x + x;
	first.y := first.y + y;
	first.z := first.z + z;
end;



procedure InitGraph(var graphIn: Graph; i, j: integer);
begin
	graphIn.i := i;
	graphIn.j := j;
end;



procedure InitPoint(var pointIn: Point; x, y, z: double);
begin
	PointIn.x := x;
	PointIn.oldX := x;
	
	PointIn.y := y;
	PointIn.oldY := y;
	
	PointIn.z := z;
	PointIn.oldZ := z;
	
	InitAngles(pointIn.angle, 0.0, 0.0, 0.0);
end;

procedure UpdatePointXYZ(var pointIn: Point; x, y, z: double);
begin
	PointIn.x := x;
	PointIn.y := y;
	PointIn.z := z;
end;

procedure RotatePoint(var pointIn: Point; pointCenter: Point; angleIn: Angles);
var
	tempX, tempY, tempZ: double;
	radX, radY, radZ: double;
	sinX, cosX, sinY, cosY, sinZ, cosZ: double;
	transX, transY, transZ: double;
begin
	radX := angleIn.x * DEG_TO_RAD;
	radY := angleIn.y * DEG_TO_RAD;
	radZ := angleIn.z * DEG_TO_RAD;

	sinX := sin(radX);
	cosX := cos(radX);
	sinY := sin(radY);
	cosY := cos(radY);
	sinZ := sin(radZ);
	cosZ := cos(radZ);

	transX := pointIn.oldX - pointCenter.x;
	transY := pointIn.oldY - pointCenter.y;
	transZ := pointIn.oldZ - pointCenter.z;

	tempY := transY * cosX - transZ * sinX;
	tempZ := transY * sinX + transZ * cosX;
	transY := tempY;
	transZ := tempZ;

	tempX := transX * cosY + transZ * sinY;
	tempZ := -transX * sinY + transZ * cosY;
	transX := tempX;
	transZ := tempZ;

	tempX := transX * cosZ - transY * sinZ;
	tempY := transX * sinZ + transY * cosZ;
	transX := tempX;
	transY := tempY;

	pointIn.x := pointCenter.x + transX;
	pointIn.y := pointCenter.y + transY;
	pointIn.z := pointCenter.z + transZ;
end;

procedure DrawPoint(PointIn: Point);
begin
	glPointSize(STD_POINT_SIZE_FROM_ARG);
	glBegin(GL_POINTS);
		glColor3f(1.0, 1.0, 1.0);
		glVertex3f(PointIn.x / GLOB_K_FROM_ARG, 
				   PointIn.y / GLOB_K_FROM_ARG, 
				   PointIn.z / GLOB_K_FROM_ARG);
	glEnd;
end;


procedure ComputeLineCenter(var lineIn: Line);
var
	xa, ya, za: double;
	xb, yb, zb: double;
begin
	xa := lineIn.vertexA.x; xb := lineIn.vertexB.x;
	ya := lineIn.vertexA.y; yb := lineIn.vertexB.y;
	za := lineIn.vertexA.z; zb := lineIn.vertexB.z;

	UpdatePointXYZ(lineIn.pointCenter,
		(xa + xb) / 2.0, (ya + yb) / 2.0, (za + zb) / 2.0); 
end;

procedure ComputeLineLength(var lineIn: Line);
var
	xa, ya, za: double;
	xb, yb, zb: double;
begin
	xa := lineIn.vertexA.x; xb := lineIn.vertexB.x;
	ya := lineIn.vertexA.y; yb := lineIn.vertexB.y;
	za := lineIn.vertexA.z; zb := lineIn.vertexB.z;

	lineIn.length := sqrt((xb - xa)*(xb - xa) + 
		(yb - ya)*(yb - ya) + (zb - za)*(zb - za));
end;

procedure InitLine(var lineIn: Line; vertexA, vertexB: Point);
begin
	lineIn.vertexA := vertexA;
	lineIn.vertexB := vertexB;

	InitAngles(lineIn.angle, 0.0, 0.0, 0.0);
end;

procedure RotateLine(var lineIn: line; pointCenter: Point; angleIn: Angles);
begin
	InitAngles(LineIn.angle, angleIn.x, angleIn.y, angleIn.z);
	
	RotatePoint(lineIn.vertexA, pointCenter, lineIn.angle);
	RotatePoint(lineIn.vertexB, pointCenter, lineIn.angle);

	lineIn.pointCenter.x := (lineIn.vertexA.x + lineIn.vertexB.x) / 2.0;
	lineIn.pointCenter.y := (lineIn.vertexA.y + lineIn.vertexB.y) / 2.0;
	lineIn.pointCenter.z := (lineIn.vertexA.z + lineIn.vertexB.z) / 2.0;
end;

procedure DrawLine(lineIn: Line);
var
	dx, dy, sx, sy, err: double; 
	e2, x1, x2, y1, y2: double;
	temp: point;
begin
	x1 := round(lineIn.vertexA.x);
	y1 := round(lineIn.vertexA.y);
	x2 := round(lineIn.vertexB.x);
	y2 := round(lineIn.vertexB.y);

	dx := abs(x2 - x1);
	dy := abs(y2 - y1);

	if x1 < x2 then
		sx := 1
	else
		sx := -1;
	if y1 < y2 then
		sy := 1
	else
		sy := -1;
	err := dx - dy;

	while (x1 <> x2) or (y1 <> y2) do
	begin
		InitPoint(temp, x1, y1, 0);
		DrawPoint(temp);
		e2 := 2 * err;
		if e2 > -dy then
		begin
			err := err - dy;
			x1 := x1 + sx
		end;
		if e2 < dx then
		begin
			err := err + dx;
			y1 := y1 + sy
		end
	end;
	InitPoint(temp, x1, y1, 0);
	DrawPoint(temp);
end;


procedure ParseVerteces(parts: StringArray; var PrimIn: Primitive);
var
	x, y, z: double;
begin
	x := StrToFloat(parts[1]);
	y := StrToFloat(parts[2]);
	z := StrToFloat(parts[3]);

	SetLength(PrimIn.vertex, Length(PrimIn.vertex) + 1);
	InitPoint(PrimIn.vertex[High(PrimIn.vertex)],
		x * XYZ_K_FROM_ARG, y * XYZ_K_FROM_ARG, z * XYZ_K_FROM_ARG)
end;


procedure ParseFaces(parts: StringArray; var PrimIn: Primitive);
var
	v1, v2, v3: string;
	i: integer;
begin
	for i := 2 to Length(parts) - 2 do
	begin
		v1 := parts[1];
		v2 := parts[i];
		v3 := parts[i + 1];
		
		if pos('/', v1) > 0 then
			v1 := Copy(v1, 1, pos('/', v1) - 1);
		if pos('/', v2) > 0 then
			v2 := Copy(v2, 1, pos('/', v2) - 1);
		if pos('/', v3) > 0 then
			v3 := Copy(v3, 1, pos('/', v3) - 1);
		
		SetLength(PrimIn.graphs, Length(PrimIn.graphs) + 1);
		InitGraph(PrimIn.graphs[High(PrimIn.graphs)], 
			StrToInt(v1), StrToInt(v2));
		
		SetLength(PrimIn.graphs, Length(PrimIn.graphs) + 1);
		InitGraph(PrimIn.graphs[High(PrimIn.graphs)], 
			StrToInt(v2), StrToInt(v3));
		
		SetLength(PrimIn.graphs, Length(PrimIn.graphs) + 1);
		InitGraph(PrimIn.graphs[High(PrimIn.graphs)], 
			StrToInt(v3), StrToInt(v1))
	end

end;


procedure ParseObjFile(name: string; var PrimIn: Primitive);
var
	objFile: text;
	tempStr: string;
	parts: StringArray;
begin
	SetLength(PrimIn.graphs, 0);
	SetLength(PrimIn.vertex, 0);
	
	assign(objFile, name);
	reset(objFile);
	
	while not SeekEOF(objFile) do begin
		readln(objFile, tempStr);
		tempStr := Trim(tempStr);
		
		if Length(tempStr) = 0 then 
			continue;
		
		SetLength(parts, 0);
		while pos(' ', tempStr) > 0 do begin
			SetLength(parts, Length(parts) + 1);
			parts[High(parts)] := Copy(tempStr, 1, pos(' ', tempStr) - 1);
			tempStr := Copy(tempStr, pos(' ', tempStr) + 1, Length(tempStr));
		end;

		if tempStr <> '' then begin
			SetLength(parts, Length(parts) + 1);
			parts[High(parts)] := tempStr;
		end;
		
		if (Length(parts) > 0) then begin 
			if parts[0] = 'v' then
				ParseVerteces(parts, PrimIn);
			if parts[0] = 'f' then
				ParseFaces(parts, PrimIn);	
		end;
	end;
	
	close(objFile);
end;


procedure RotatePrimitive(var PrimIn: Primitive; pointCenter: Point; angleIn: Angles);
var
	i: integer;
begin
	for i := 0 to Length(PrimIn.vertex) do
		RotatePoint(PrimIn.vertex[i], pointCenter, angleIn);
end;


procedure DrawPrimitive(var PrimIn: Primitive);
var
	n: integer;
	tempStr: Line;
	vertexIDF, vertexIDS: integer;
begin
	for n := 0 to Length(PrimIn.graphs) - 1 do
	begin
		vertexIDF := PrimIn.graphs[n].i - 1;
		vertexIDS := PrimIn.graphs[n].j - 1;	
		InitLine(tempStr, PrimIn.vertex[vertexIDF], 
						   PrimIn.vertex[vertexIDS]);
		DrawLine(tempStr);
	end;
end;



end.

