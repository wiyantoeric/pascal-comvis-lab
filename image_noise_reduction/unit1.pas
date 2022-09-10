unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtDlgs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLoad: TButton;
    ButtonSave: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
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
  bitmapR, bitmapG, bitmapB, bitmapGray, bitmapGrayFilter, bitmapRedFilter, bitmapGreenFilter, bitmapBlueFilter : array[-1..1000,-1..1000] of integer;

procedure TForm1.ButtonLoadClick(Sender: TObject);
                             
var
  j, i, ki, kj, r, g, b, gray, kRed, kGreen, kBlue : integer;
  smoothingFilter : array[0..2,0..2] of single = ((1/9,1/9,1/9),(1/9,1/9,1/9),(1/9,1/9,1/9));
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;                              

  image2.Width :=image1.width;
  image2.height:=image1.height;

  image3.Width :=image1.width;
  image3.height:=image1.height;

  image4.Width :=image1.width;
  image4.height:=image1.height;

  for j:=0 to image1.Height-1 do
  begin
    for i:=0 to image1.Width-1 do
    begin
      //mengambil nilai RGB
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      gray := (R + G + B) div 3;
      bitmapR[i,j] := R;
      bitmapG[i,j] := G;
      bitmapB[i,j] := B;
      bitmapGray[i,j] := gray;

      // mengisi tepi image
      if (i = 0) or (j = 0) or (i = image1.width-1) or (j = image1.height-1) then
      begin
        if i = 0 then
        begin
          bitmapR[i-1,j] := bitmapR[i,j];
          bitmapG[i-1,j] := bitmapG[i,j];
          bitmapB[i-1,j] := bitmapB[i,j];
          bitmapGray[i-1,j] := bitmapGray[i,j];
        end;
        if j = 0 then
        begin
          bitmapR[i,j-1] := bitmapR[i,j];
          bitmapG[i,j-1] := bitmapG[i,j];
          bitmapB[i,j-1] := bitmapB[i,j];
          bitmapGray[i,j-1] := bitmapGray[i,j];
        end;
        if i = image1.width-1 then
        begin
          bitmapR[i+1,j] := bitmapR[i,j];
          bitmapG[i+1,j] := bitmapG[i,j];
          bitmapB[i+1,j] := bitmapB[i,j];
          bitmapGray[i+1,j] := bitmapGray[i,j];
        end;
        if j = image1.height-1 then
        begin
          bitmapR[i,j+1] := bitmapR[i,j];
          bitmapG[i,j+1] := bitmapG[i,j];
          bitmapB[i,j+1] := bitmapB[i,j];
          bitmapGray[i,j+1] := bitmapGray[i,j];
        end;
      end;

      image1.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);
    end;
  end;

  // blur
  for j:=0 to image1.Height-1 do
  begin
    for i:=0 to image1.Width-1 do
    begin
      kRed := 0;
      kGreen := 0;
      kBlue := 0;

      // filtering
      for ki:=0 to 2 do
      begin
        for kj:=0 to 2 do
        begin
          kRed := round(kRed + bitmapR[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kGreen := round(kGreen + bitmapG[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kBlue := round(kBlue + bitmapB[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
        end;
      end;

      bitmapRedFilter[i,j] := kRed;
      bitmapGreenFilter[i,j] := kGreen;
      bitmapBlueFilter[i,j] := kBlue;
      image2.canvas.pixels[i,j] := RGB(kRed, kGreen, kBlue);
    end;
  end;

  // grayscale
  for j:=0 to image1.Height-1 do
  begin
    for i:=0 to image1.Width-1 do
    begin
      bitmapGrayFilter[i,j] := (bitmapRedFilter[i,j] + bitmapGreenFilter[i,j] + bitmapBlueFilter[i,j]) div 3;
      image3.canvas.pixels[i,j] := RGB(bitmapGrayFilter[i,j],bitmapGrayFilter[i,j],bitmapGrayFilter[i,j]);
    end;
  end;

  // output biner
  for j:=0 to image1.Height-1 do
  begin
    for i:=0 to image1.Width-1 do
    begin
      if bitmapGrayFilter[i,j] > 127 then image4.canvas.pixels[i,j] := RGB(255,255,255) else image3.canvas.pixels[i,j] := RGB(0,0,0);
    end;
  end;

end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
begin
  if (SavePictureDialog1.Execute) then
  begin
    image4.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

end.

