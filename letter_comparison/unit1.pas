unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ExtDlgs;

type

  { TForm1 }

  TForm1 = class(TForm)
    Compare: TButton;
    LoadImage1: TButton;
    LoadImage2: TButton;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure CompareClick(Sender: TObject);
    procedure LoadImage1Click(Sender: TObject);
    procedure LoadImage2Click(Sender: TObject);
    procedure SegmentasiImage1();
    procedure SegmentasiImage2();
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses
  windows, math;

var
  bmpGray1, bmpGray2, bmpBiner1, bmpBiner2 : array[0..1000, 0..1000] of integer;
  tepiAtas1, tepiBawah1, tepiKiri1, tepiKanan1 : integer;
  tepiAtas2, tepiBawah2, tepiKiri2, tepiKanan2 : integer;
  object1Width, object1Height, object2Width, object2Height : integer;

procedure TForm1.LoadImage1Click(Sender: TObject);
var
  i, j : integer;
  R, G, B : integer;
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;

//  ekstraksi warna dan menhitung warna grayscale
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      bmpGray1[i,j] := (R + G + B) div 3;

      if bmpGray1[i,j] > 127
      then
        bmpBiner1[i,j] := 1
      else
        bmpBiner1[i,j] := 0;
    end;
  end;
end;

procedure TForm1.CompareClick(Sender: TObject);
var
  i, j : integer;
  population1, population2 : array[0..24,0..24] of single;
  matrixRow, matrixCol : integer;
  binaryCount : integer = 0;
  matrixWidth, matrixHeight : integer;
  matrixCount : integer = 5;
  maxObjectWidth : integer = 0;
  maxObjectHeight : integer = 0;
  metricValue : single = 0;
begin
  segmentasiImage1();
  segmentasiImage2();

  maxObjectWidth := max(object1Width, object2Width);
  maxObjectHeight := max(object1Height, object2Height);
             
//  menghitung populasi object 1
  matrixWidth := ceil(object1Width / matrixCount);
  matrixHeight := ceil(object1Height / matrixCount);
  for i:=0 to matrixCount-1 do
  begin
    for j:=0 to matrixCount-1 do
    begin
      binaryCount := 0;
      for matrixRow:=0 to matrixWidth-1 do
      begin
        for matrixCol:=0 to matrixHeight-1 do
        begin
          if bmpBiner1[tepiKiri1 + (i*matrixWidth) + matrixRow, tepiAtas1 + (j*matrixHeight) + matrixCol] = 0 then inc(binaryCount);
        end;
      end;
      population1[i,j] := binaryCount / (matrixWidth*matrixHeight);

      memo1.lines.add('Fitur [' + intToStr(i) + ']' + '[' + intToStr(j) + '] : ' + floatToStr(population1[i][j] * 100) + '%');
    end;
  end;
              
  matrixWidth := ceil(object2Width / matrixCount);
  matrixHeight := ceil(object2Height / matrixCount);
//  menghitung populasi object 2
  for i:=0 to matrixCount-1 do
  begin
    for j:=0 to matrixCount-1 do
    begin
      binaryCount := 0;
      for matrixRow:=0 to matrixWidth-1 do
      begin
        for matrixCol:=0 to matrixHeight-1 do
        begin
          if bmpBiner2[tepiKiri2 + (i*matrixWidth) + matrixRow, tepiAtas2 + (j*matrixHeight) + matrixCol] = 0 then inc(binaryCount);
        end;
      end;
      population2[i,j] := binaryCount / (matrixWidth*matrixHeight);

      memo2.lines.add('Fitur [' + intToStr(i) + ']' + '[' + intToStr(j) + '] : ' + floatToStr(population2[i][j] * 100) + '%');
    end;
  end;

//  menghitung L1 metric
  for i:=0 to matrixCount-1 do
  begin
    for j:=0 to matrixCount-1 do
    begin
      metricValue += abs(population1[i,j]-population2[i,j]);
    end;
  end;

//  print hasil
  if metricValue <= 5 then
    label1.caption := 'Mirip, kemiripan tinggi dengan nilai L1: ' + floatToStr(metricValue)
  else
    label1.caption := 'Tidak mirip, kemiripan rendah dengan nilai L1: ' + floatToStr(metricValue);
  label1.visible := true;
end;

procedure TForm1.LoadImage2Click(Sender: TObject);
var
  i, j : integer;
  R, G, B : integer;
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image2.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;

//  mengambil nilai biner Image
  for i:=0 to image2.Width-1 do
  begin
    for j:=0 to image2.Height-1 do
    begin
      R := GetRValue(image2.Canvas.Pixels[i,j]);
      G := GetGValue(image2.Canvas.Pixels[i,j]);
      B := GetBValue(image2.Canvas.Pixels[i,j]);

      bmpGray2[i,j] := (R + G + B) div 3;

      if bmpGray2[i,j] > 127
      then
        bmpBiner2[i,j] := 1
      else
        bmpBiner2[i,j] := 0;
    end;
  end;
end;

procedure TForm1.SegmentasiImage1();
var
  i, j : integer;      
  tepi : array[0..3] of integer;
label
  labelAtas, labelKanan, labelBawah, labelDraw;
begin
  // tepi
  //    0
  // 3     1
  //    2

  //  tepi kiri
    for i:=0 to image1.width-1 do
    begin
      for j:=0 to image1.height-1 do
      begin
        if (bmpBiner1[i,j] = 0) then
        begin
          tepi[3] := i;
          goto labelAtas;
        end;
      end;
    end;

//    tepi atas
    labelAtas:
    for i:=0 to image1.width-1 do
    begin
      for j:=0 to image1.height-1 do
      begin
        if (bmpBiner1[j,i] = 0) then
        begin
          tepi[0] := i;
          goto labelkanan;
        end;
      end;
    end;

//    tepi kanan
    labelKanan:
    i:=image1.width-1;
    while i >= 0 do
    begin
      for j:=0 to image1.Height-1 do
      begin
        if (bmpBiner1[i,j] = 0) then
        begin
          tepi[1] := i;
          goto labelbawah;
        end;
      end;
      i := i-1;
    end;

    //  tepi bawah
    labelBawah:
    i:=image1.height-1;
    while i >= 0 do
    begin
      j:=image1.width-1;
      while j >= 0 do
      begin
        if (bmpBiner1[j,i] = 0) then
        begin
          tepi[2] := i;
          goto labelDraw;
        end;
        j := j-1;
      end;
      i := i-1;
    end;
              
//    menggambar kotak di sekitar huruf yang tersegmentasi
    labelDraw:

    image1.canvas.pen.color := clred;

    image1.canvas.moveTo(tepi[3], tepi[0]);
    image1.canvas.lineTo(tepi[1], tepi[0]);

    image1.canvas.lineTo(tepi[1], tepi[2]);

    image1.canvas.lineTo(tepi[3], tepi[2]);

    image1.canvas.lineTo(tepi[3], tepi[0]);

    tepiAtas1 := tepi[0];
    tepiBawah1 := tepi[2];
    tepiKiri1 := tepi[3];
    tepiKanan1 := tepi[1];

    object1Width := tepi[1]-tepi[3];
    object1Height := tepi[2]-tepi[0];
end;

procedure TForm1.SegmentasiImage2();
var
  i, j : integer;             
  tepi : array[0..3] of integer;
label
  labelAtas, labelKanan, labelBawah, labelDraw;
begin     
  // tepi
  //    0
  // 3     1
  //    2

  //  tepi kiri
    for i:=0 to image2.Width-1 do
    begin
      for j:=0 to image2.Height-1 do
      begin
        if (bmpBiner2[i,j] = 0) then
        begin
          tepi[3] := i;
          goto labelAtas;
        end;
      end;
    end;

//    tepi atas
    labelAtas:
    for i:=0 to image2.width-1 do
    begin
      for j:=0 to image2.height-1 do
      begin
        if (bmpBiner2[j,i] = 0) then
        begin
          tepi[0] := i;
          goto labelkanan;
        end;
      end;
    end;

//    tepi kanan
    labelKanan:
    i:=image2.width-1;
    while i >= 0 do
    begin
      for j:=0 to image2.Height-1 do
      begin
        if (bmpBiner2[i,j] = 0) then
        begin
          tepi[1] := i;
          goto labelbawah;
        end;
      end;
      i := i-1;
    end;

//    tepi bawah
    labelBawah:
    i:=image2.height-1;
    while i >= 0 do
    begin
      j:=image2.width-1;
      while j >= 0 do
      begin
        if (bmpBiner2[j,i] = 0) then
        begin
          tepi[2] := i;
          goto labelDraw;
        end;
        j := j-1;
      end;
      i := i-1;
    end;

//    menggambar kotak di sekitar huruf yang tersegmentasi
    labelDraw:

    image2.canvas.pen.color := clred;

    image2.canvas.moveTo(tepi[3], tepi[0]);
    image2.canvas.lineTo(tepi[1], tepi[0]);

    image2.canvas.lineTo(tepi[1], tepi[2]);

    image2.canvas.lineTo(tepi[3], tepi[2]);

    image2.canvas.lineTo(tepi[3], tepi[0]);

    tepiAtas2 := tepi[0];
    tepiBawah2 := tepi[2];
    tepiKiri2 := tepi[3];
    tepiKanan2 := tepi[1];

    object2Width := tepi[1]-tepi[3];
    object2Height := tepi[2]-tepi[0];
end;

end.

