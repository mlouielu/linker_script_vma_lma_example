SECTIONS
{
	. = 0x0;
	abc :
	{
		*(abc)
	}

	. = 0x1000;
	def : AT( ADDR(abc) + SIZEOF(abc) )
	{
		*(def)
	}

	/DISCARD/ : { *(.note.gnu.build-id) }
	/DISCARD/ : { *(.comment) }
}

