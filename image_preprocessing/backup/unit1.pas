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
    Image5: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  bitmapR, bitmapG, bitmapB, bitmapGray, bitmapbiner : array[-2..1000,-2..1000] of integer;

procedure TForm1.ButtonLoadClick(Sender: TObject);
                             
var
  j, i, ki, kj, r, g, b, gray, kred, kgreen, kblue, kgray, kbiner : integer;
  smoothingKernel : Array [1..5,1..5] of integer = (
                  (2,4,5,4,2),
                  (4,9,12,9,4),
                  (5,12,15,12,5),
                  (4,9,12,9,4),
                  (2,4,5,4,2)
  );

begin

  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;                              

  image2.Width :=image1.width;
  image2.height:=image1.height;

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
          bitmapR[i-2,j] := bitmapR[i,j];
          bitmapG[i-1,j] := bitmapG[i,j];
          bitmapG[i-2,j] := bitmapG[i,j];
          bitmapB[i-1,j] := bitmapB[i,j]; 
          bitmapB[i-2,j] := bitmapB[i,j];
          bitmapGray[i-1,j] := bitmapGray[i,j]; 
          bitmapGray[i-2,j] := bitmapGray[i,j];
        end;
        if j = 0 then
        begin
          bitmapR[i,j-1] := bitmapR[i,j];  
          bitmapR[i,j-2] := bitmapR[i,j];
          bitmapG[i,j-1] := bitmapG[i,j];  
          bitmapG[i,j-2] := bitmapG[i,j];
          bitmapB[i,j-1] := bitmapB[i,j];  
          bitmapB[i,j-2] := bitmapB[i,j];
          bitmapGray[i,j-1] := bitmapGray[i,j];
          bitmapGray[i,j-2] := bitmapGray[i,j];
        end;
        if i = image1.width-1 then
        begin
          bitmapR[i+1,j] := bitmapR[i,j];  
          bitmapR[i+2,j] := bitmapR[i,j];
          bitmapG[i+1,j] := bitmapG[i,j]; 
          bitmapG[i+2,j] := bitmapG[i,j];
          bitmapB[i+1,j] := bitmapB[i,j];  
          bitmapB[i+2,j] := bitmapB[i,j];
          bitmapGray[i+1,j] := bitmapGray[i,j];  
          bitmapGray[i+2,j] := bitmapGray[i,j];
        end;
        if j = image1.height-1 then
        begin
          bitmapR[i,j+1] := bitmapR[i,j]; 
          bitmapR[i,j+2] := bitmapR[i,j];
          bitmapG[i,j+1] := bitmapG[i,j];  
          bitmapG[i,j+2] := bitmapG[i,j];
          bitmapB[i,j+1] := bitmapB[i,j];    
          bitmapB[i,j+2] := bitmapB[i,j];
          bitmapGray[i,j+1] := bitmapGray[i,j]; 
          bitmapGray[i,j+2] := bitmapGray[i,j];
        end;
      end;

      image1.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);

      if (gray > 127) then bitmapbiner[i,j] := 1 else bitmapbiner[i,j] := 0;

      image2.canvas.pixels[i,j] := RGB(bitmapbiner[i,j] * 255, bitmapbiner[i,j] * 255, bitmapbiner[i,j] * 255);
    end;
  end;

  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      kgray := 0;
      kred := 0;
      kgreen := 0;
      kblue := 0;
      kbiner := 0;

      for ki:=1 to 5 do
      begin
        for kj:=1 to 5 do
        begin
          kgray := round(kgray + bitmapgray[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kred := round(kred + bitmapr[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kgreen := round(kgreen + bitmapg[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kblue := round(kblue + bitmapb[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);  
          kbiner := round(kbiner + bitmapbiner[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
        end;
      end;

      kgray := round(kgray/159);    
      kred := round(kred/159);
      kgreen := round(kgreen/159);
      kblue := round(kblue/159);    
      kbiner := round(kbiner/159);

      if kgray > 255 then kgray := 255;
      if kgray < 0 then kgray := 0;

      if kred > 255 then kred := 255;
      if kred < 0 then kred := 0;

      if kgreen > 255 then kgreen := 255;
      if kgreen < 0 then kgreen := 0;

      if kblue > 255 then kblue := 255;
      if kblue < 0 then kblue := 0;

      if kbiner > 255 then kbiner := 255;
      if kbiner < 0 then kbiner := 0;

      image3.canvas.pixels[i,j] := RGB(kred,kgreen,kblue);
      image4.canvas.pixels[i,j] := RGB(kgray,kgray,kgray);
      image5.canvas.pixels[i,j] := RGB(kbiner*255,kbiner*255,kbiner*255);
    end;
  end;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
begin
  if (SavePictureDialog1.Execute) then
  begin
    image2.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.

