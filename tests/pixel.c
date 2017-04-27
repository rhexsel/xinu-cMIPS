/*
	XeaM single core

*/

#include "cMIPS.h"

#define dataBaseAddress 	0x00004000
#define dataFileSize 		0x00000004	// Tamanho do data.bin original

#define larguraImagem		100		// Sempre alterar para largura da imagem em pixels
#define alturaImagem 		100		// Sempre alterar para altura da imagem em pixels

#define tamanhoHead			56/4	// 54 byte of the .bmp header + 2 extra null bytes

#define totalPixelImg	 		larguraImagem*alturaImagem

typedef struct Pixel{
	unsigned char b; // blue
	unsigned char g; // green
	unsigned char r; // red
	unsigned char a; // alpha
}pixel;

typedef union Un{
	pixel p;		
	int i;
}un;

	pixel *imgHead;	// Vetor Cabeçalho
	pixel *imgBase;	// Vetor Base da imagem
	un p;

// Contraste
enum contrasteCfg{
	CINACTIVE,	// Contraste desligado
	CVERMELHO, 	// Contraste vermelho
	CVERDE,		// Contraste verde
	CCINZA		// Contraste cinza
};

// Configuração de Contraste
enum contrasteCfg contrastecfg = CVERDE;

int main(void) {
	
	imgHead	= (pixel*) (dataBaseAddress + dataFileSize);
	imgBase = (pixel*) (dataBaseAddress + dataFileSize + tamanhoHead);

	//dumpRAM();

	int i;

	for(i = 0; i < tamanhoHead; i++){
		print( (int) (imgHead+i));
		p.p = (pixel) *(imgHead+i);
		print((int)p.i);
	}

	return;

	// exit(0);
}
