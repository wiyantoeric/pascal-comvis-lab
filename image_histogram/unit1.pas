unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtDlgs,
  ExtCtrls, TAGraph;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLoad: TButton;
    Image1: TImage;
    Histogram: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure ButtonLoadClick(Sender: TObject);
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
  bmpGray : array[0..1000,0..1000] of integer;
  hgGray : array[0..255] of integer;

procedure TForm1.ButtonLoadClick(Sender: TObject);
var
  i, j : integer;
  r, g, b : integer;
  highestVal : integer = 0;
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;

//  memasukkan warna ke bitmap
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      bmpGray[i,j] := (R + G + B) div 3;
    end;
  end;

//  inisialisasi dengan nilai 0
  for i:=0 to image1.Width-1 do
  begin
    hgGray[i] := 0;
  end;

//  mengisi histogram grayscale
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      hgGray[bmpGray[i,j]] := hgGray[bmpGray[i,j]] + 1;
    end;
  end;

  histogram.Canvas.Brush.Color := ClWhite;
  histogram.Canvas.FillRect(0, 0, histogram.Width, histogram.Height);

  Histogram.Canvas.Pen.Color := clBlack;
  Histogram.Canvas.Pen.Width := 1;
  Histogram.Canvas.Pen.Style := psSolid;


  histogram.width := 255;
  histogram.height := 255;


  for i:=0 to 255 do
  begin
    if highestVal < hgGray[i] then highestVal := hgGray[i];
  end;


  for i:=0 to 255 do
  begin
    histogram.canvas.moveTo(i, histogram.height-1);
    histogram.canvas.lineTo(i, hgGray[i]);
  end;
end;

end.

