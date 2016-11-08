SECTIONS
{
	. = 0x0;
	abc :
	{
		*(abc)
	}
	def :
	{
		*(def)
	}

	/DISCARD/ : { *(.note.gnu.build-id) }
	/DISCARD/ : { *(.comment) }
}

