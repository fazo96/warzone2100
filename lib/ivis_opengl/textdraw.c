/*
	This file is part of Warzone 2100.
	Copyright (C) 1999-2004  Eidos Interactive
	Copyright (C) 2005-2009  Warzone Resurrection Project

	Warzone 2100 is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Warzone 2100 is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Warzone 2100; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include <GLee.h>
#include "lib/framework/frame.h"
#include <stdlib.h>
#include <string.h>
#include "lib/framework/string_ext.h"
#include "lib/ivis_common/ivisdef.h"
#include "lib/ivis_common/piestate.h"
#include "lib/ivis_common/rendmode.h"
#include "lib/ivis_common/pieclip.h"
#include "lib/ivis_common/pieblitfunc.h"
#include "lib/ivis_common/piepalette.h"
#include "lib/ivis_common/ivispatch.h"
#include "lib/ivis_common/textdraw.h"
#include "lib/ivis_common/bitimage.h"

/** Draws formatted text with word wrap, long word splitting, embedded newlines
 *  (uses '@' rather than '\n') and colour toggle mode ('#') which enables or
 *  disables font colouring.
 *
 *  @param String   the string to display.
 *  @param x,y      X and Y coordinates of top left of formatted text.
 *  @param width    the maximum width of the formatted text (beyond which line
 *                  wrapping is used).
 *  @param justify  The alignment style to use, which is one of the following:
 *                  FTEXT_LEFTJUSTIFY, FTEXT_CENTRE or FTEXT_RIGHTJUSTIFY.
 *  @return the Y coordinate for the next text line.
 */
int iV_DrawFormattedText(const char* String, UDWORD x, UDWORD y, UDWORD Width, UDWORD Justify)
{
	char FString[256];
	char FWord[256];
	int i;
	int jx = x;		// Default to left justify.
	int jy = y;
	UDWORD WWidth;
	int TWidth;
	const char* curChar = String;

	while (*curChar != 0)
	{
		bool GotSpace = false;
		bool NewLine = false;

		// Reset text draw buffer
		FString[0] = 0;

		WWidth = 0;

		// Parse through the string, adding words until width is achieved.
		while (*curChar != 0 && WWidth < Width && !NewLine)
		{
			const char* startOfWord = curChar;
			const unsigned int FStringWidth = iV_GetTextWidth(FString);

			// Get the next word.
			i = 0;
			for (; *curChar != 0
			    && *curChar != ASCII_SPACE
			    && *curChar != ASCII_NEWLINE
			    && *curChar != '\n';
			     ++i, ++curChar)
			{
				if (*curChar == ASCII_COLOURMODE) // If it's a colour mode toggle char then just add it to the word.
				{
					FWord[i] = *curChar;

					// this character won't be drawn so don't deal with its width
					continue;
				}

				// Update this line's pixel width.
				WWidth = FStringWidth + iV_GetCountedTextWidth(FWord, i + 1);

				// If this word doesn't fit on the current line then break out
				if (WWidth > Width)
				{
					break;
				}

				// If width ok then add this character to the current word.
				FWord[i] = *curChar;
			}

			// Don't forget the space.
			if (*curChar == ASCII_SPACE)
			{
				// Should be a space below, not '-', but need to work around bug in QuesoGLC
				// which was fixed in CVS snapshot as of 2007/10/26, same day as I reported it :) - Per
				WWidth += iV_GetCharWidth('-');
				if (WWidth <= Width)
				{
					FWord[i] = ' ';
					++i;
					++curChar;
					GotSpace = true;
				}
			}
			// Check for new line character.
			else if (*curChar == ASCII_NEWLINE
			      || *curChar == '\n')
			{
				NewLine = true;
				++curChar;
			}

			// If we've passed a space on this line and the word goes past the
			// maximum width and this isn't caused by the appended space then
			// rewind to the start of this word and finish this line.
			if (GotSpace
			 && WWidth > Width
			 && FWord[i - 1] != ' ')
			{
				// Skip back to the beginning of this
				// word and draw it on the next line
				curChar = startOfWord;
				break;
			}

			// Terminate the word.
			FWord[i] = 0;

			// And add it to the output string.
			sstrcat(FString, FWord);
		}


		// Remove trailing spaces, useful when doing center alignment.
		{
			// Find the string length (the "minus one" part
			// guarantees that we get the length of the string, not
			// the buffer size required to contain it).
			size_t len = strnlen1(FString, sizeof(FString)) - 1;

			for (; len != 0; --len)
			{
				// As soon as we encounter a non-space character, break out
				if (FString[len] != ASCII_SPACE)
					break;

				// Cut off the current space character from the string
				FString[len] = '\0';
			}
		}

		TWidth = iV_GetTextWidth(FString);

		// Do justify.
		switch (Justify)
		{
			case FTEXT_CENTRE:
				jx = x + (Width - TWidth) / 2;
				break;

			case FTEXT_RIGHTJUSTIFY:
				jx = x + Width - TWidth;
				break;

			case FTEXT_LEFTJUSTIFY:
				jx = x;
				break;
		}

		// draw the text.
		//iV_SetTextSize(12.f);
		iV_DrawText(FString, jx, jy);

		// and move down a line.
		jy += iV_GetTextLineSize();
	}

	return jy;
}

static void iV_DrawTextRotatedFv(float x, float y, float rotation, const char* format, va_list ap)
{
	va_list aq;
	size_t size;
	char* str;

	/* Required because we're using the va_list ap twice otherwise, which
	 * results in undefined behaviour. See stdarg(3) for details.
	 */
	va_copy(aq, ap);

	// Allocate a buffer large enough to hold our string on the stack
	size = vsnprintf(NULL, 0, format, ap);
	str = alloca(size + 1);

	// Print into our newly created string buffer
	vsprintf(str, format, aq);

	va_end(aq);

	// Draw the produced string to the screen at the given position and rotation
	iV_DrawTextRotated(str, x, y, rotation);
}

void iV_DrawTextF(float x, float y, const char* format, ...)
{
	va_list ap;

	va_start(ap, format);
		iV_DrawTextRotatedFv(x, y, 0.f, format, ap);
	va_end(ap);
}
