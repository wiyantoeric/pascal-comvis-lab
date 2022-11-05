unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ExtDlgs;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image2: TImage;
    Label1: TLabel;
    Load: TButton;
    Image1: TImage;
    Memo1: TMemo;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    procedure LoadClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses
  windows;

var
   bmpGray, bmpBiner : array[0..1000, 0..1000] of integer;
   matrixSize : integer = 5;
   loopCount : integer = 1;

procedure TForm1.LoadClick(Sender: TObject);
var
  i, j : integer;
  R, G, B : integer;
  matrixRow, matrixCol : integer;
  binaryCount : integer = 0;
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;

  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      bmpGray[i,j] := (R + G + B) div 3;

      if bmpGray[i,j] > 127
      then
        bmpBiner[i,j] := 1
      else
        bmpBiner[i,j] := 0;
    end;
  end;

  image2.width := image1.canvas.width;
  image2.height := image1.canvas.height;
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      image2.canvas.pixels[i,j] := RGB(bmpBiner[i,j] * 255,bmpBiner[i,j] * 255,bmpBiner[i,j] * 255);
    end;
  end;

  label1.caption := 'Resolution = ' + intToStr(image1.canvas.width) + ' x ' + intToStr(image1.canvas.height);

  for i:=0 to (image1.canvas.width div matrixSize)-1 do
  begin
    for j:=0 to (image1.canvas.height div matrixSize)-1 do
    begin
      binaryCount := 0;
      for matrixRow:=0 to matrixSize-1 do
      begin
        for matrixCol:=0 to matrixSize-1 do
        begin
          if bmpBiner[i*matrixSize + matrixRow, j*matrixSize + matrixCol] = 0 then inc(binaryCount);
        end;
      end;
      Memo1.lines.add('Fitur ' + intToStr(loopCount) + ' : ' + floatToStr((binaryCount / (matrixSize*matrixSize)) * 100) + '%');
      inc(loopCount);
    end;
  end;

end;

end.

