
#import "qedefs.h"

@implementation Dict
{
    NSPointerArray* list;
}

- init
{
	self = [super init];

    list = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
	
    return self;
}

- print
{
	int	i;
	dict_t	*d;
	
	for (i=0 ; i<list.count ; i++)
	{
		d = [list pointerAtIndex: i];
		printf ("%s : %s\n",d->key, d->value);
	}
	return self;
}

/*
===========
copyFromZone

JDC
===========
*/
- copyWithZone:(NSZone *)zone
{
	id	new;
	int	i;
	dict_t	*d;
	char	*old;
	
	new = [[self class] allocWithZone: zone];
	for (i=0 ; i<list.count ; i++)
	{
		d = [list pointerAtIndex: i];
		old = d->key;
		d->key = malloc(strlen(old)+1);	
		strcpy (d->key, old);
		
		old = d->value;
		d->value = malloc(strlen(old)+1);	
		strcpy (d->value, old);
	}
	
	return new;
}

- initFromFile:(FILE *)fp
{
	self = [self init];
	return [self parseBraceBlock:fp];
}

//===============================================
//
//	Dictionary pair functions
//
//===============================================

//
//	Write a { } block out to a FILE*
//
- writeBlockTo:(FILE *)fp
{
	int		max;
	int		i;
	dict_t	*d;
	
	fprintf(fp,"{\n");
	max = [list count];
	for (i = 0;i < max;i++)
	{
		d = [list pointerAtIndex:i];
		fprintf(fp,"\t{\"%s\"\t\"%s\"}\n",d->key,d->value);
	}
	fprintf(fp,"}\n");
	
	return self;
}

//
//	Write a single { } block out
//
- writeFile:(char *)path
{
	FILE	*fp;
	
	fp = fopen(path,"w+t");
	if (fp != NULL)
	{
		printf("Writing dictionary file %s.\n",path);
		fprintf(fp,"// QE_Project file %s\n",path);
		[self writeBlockTo:fp];
		fclose(fp);
	}
	else
	{
		printf("Error writing %s!\n",path);
		return NULL;
	}

	return self;
}

//===============================================
//
//	Utility methods
//
//===============================================

//
//	Find a keyword in storage
//	Returns * to dict_t, otherwise NULL
//
- (dict_t *) findKeyword:(char *)key
{	
	int		max;
	int		i;
	dict_t	*d;
	
	max = [list count];
	for (i = 0;i < max;i++)
	{
		d = [list pointerAtIndex:i];
		if (!strcmp(d->key,key))
			return d;
	}
	
	return NULL;
}

//
//	Change a keyword's string
//
- changeStringFor:(char *)key to:(char *)value
{
	dict_t	*d;
	dict_t	*newd;
	
	d = [self findKeyword:key];
	if (d != NULL)
	{
		free(d->value);
		d->value = malloc(strlen(value)+1);
		strcpy(d->value,value);
	}
	else
	{
        newd = malloc(sizeof(dict_t));
		newd->key = malloc(strlen(key)+1);
		strcpy(newd->key,key);
		newd->value = malloc(strlen(value)+1);
		strcpy(newd->value,value);
		[list addPointer:newd];
	}
	return self;
}

//
//	Search for keyword, return the string *
//
- (char *)getStringFor:(char *)name
{
	dict_t	*d;
	
	d = [self findKeyword:name];
	if (d != NULL)
		return d->value;
	
	return "";
}

//
//	Search for keyword, return the value
//
- (unsigned int)getValueFor:(char *)name
{
	dict_t	*d;
	
	d = [self findKeyword:name];
	if (d != NULL)
		return atol(d->value);
	
	return 0;
}

//
//	Return # of units in keyword's value
//
- (int) getValueUnits:(char *)key
{
	id		temp;
	int		count;
	
	temp = [self parseMultipleFrom:key];
	count = [temp count];
    for(NSUInteger i = 0; i < count; i++)
    {
        char* s = [temp pointerAtIndex:i];
        free(s);
    }
	
	return count;
}

//
//	Convert List to string
//
- (char *)convertListToString:(id)sourceList
{
	int		i;
	int		max;
	char	tempstr[4096];
	char	*s;
	char	*newstr;
	
	max = [sourceList count];
	tempstr[0] = 0;
	for (i = 0;i < max;i++)
	{
		s = [sourceList pointerAtIndex:i];
		strcat(tempstr,s);
		strcat(tempstr,"  ");
	}
	newstr = malloc(strlen(tempstr)+1);
	strcpy(newstr,tempstr);
	
	return newstr;
}

//
// JDC: I wrote this to simplify removing vectors
//
///**************************************************************- removeKeyword:(char *)key
/*{
	dict_t	*d;

	d = [self findKeyword:key];
	if (d == NULL)
		return self;
	[self removeElementAt:d - (dict_t*)dataPtr];
	return self;
}*/

//
//	Delete string from keyword's value
//
- delString:(char *)string fromValue:(char *)key
{
	id		temp;
	int		count;
	int		i;
	char	*s;
	dict_t	*d;
	
	d = [self findKeyword:key];
	if (d == NULL)
		return NULL;
	temp = [self parseMultipleFrom:key];
	count = [temp count];
	for (i = 0;i < count;i++)
	{
		s = [temp pointerAtIndex:i];
		if (!strcmp(s,string))
		{
			[temp removePointerAtIndex:i];
            free(s);
			free(d->value);
			d->value = [self convertListToString:temp];
			
			break;
		}
	}
    for(NSUInteger i = 0; i < count; i++)
    {
        char* s = [temp pointerAtIndex:i];
        free(s);
    }
	return self;
}

//
//	Add string to keyword's value
//
- addString:(char *)string toValue:(char *)key
{
	char	*newstr;
	char	spacing[] = "\t";
	dict_t	*d;
	
	d = [self findKeyword:key];
	if (d == NULL)
		return NULL;
	newstr = malloc(strlen(string) + strlen(d->value) + strlen(spacing) + 1);
	strcpy(newstr,d->value);
	strcat(newstr,spacing);
	strcat(newstr,string);
	free(d->value);
	d->value = newstr;
	
	return self;
}

//===============================================
//
//	Use these for multiple parameters in a keyword value
//
//===============================================
char	*searchStr;

- setupMultiple:(char *)value
{
	searchStr = value;
	return self;
}

- (char *)getNextParameter
{
	char	*s;
	
	if (!searchStr)
		return NULL;
    char* result = malloc(strlen(searchStr) + 1);
    strcpy(result, searchStr);
    s = FindWhitespcInBuffer(result);
	if (!*s)
		searchStr = NULL;
	else
	{
		*s = 0;
		searchStr = FindNonwhitespcInBuffer(s+1);
	}
    return result;
}

//
//	Parses a keyvalue string & returns a Storage full of those items
//
- (id) parseMultipleFrom:(char *)key
{
	#define	ITEMSIZE	128
	id		stuff;
	char	*string;
	char	*s;
	
	s = [self getStringFor:key];
	if (s == NULL)
		return NULL;
		
    stuff = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
			
	[self setupMultiple:s];
	while((s = [self getNextParameter]))
	{
		string = malloc(ITEMSIZE);
        strcpy(string, s);
		[stuff addPointer:string];
        free(s);
	}
	
	return stuff;
}

//===============================================
//
//	Dictionary pair parsing
//
//===============================================

//
//	parse all keyword/value pairs within { } 's
//
- (id) parseBraceBlock:(FILE *)fp
{
	int		c;
	dict_t	*pair;
	char	string[1024];
	
	c = FindBrace(fp);
	if (c == -1)
		return NULL;
		
	while((c = FindBrace(fp)) != '}')
	{
		if (c == -1)
			return NULL;
//		c = FindNonwhitespc(fp);
//		if (c == -1)
//			return NULL;
//		CopyUntilWhitespc(fp,string);

// JDC: fixed to allow quoted keys
		c = FindNonwhitespc(fp);
		if (c == -1)
			return NULL;
		c = fgetc(fp);
		if ( c == '\"')		
			CopyUntilQuote(fp,string);
		else
		{
			ungetc (c,fp);
			CopyUntilWhitespc(fp,string);
		}

        pair = malloc(sizeof(dict_t));
		pair->key = malloc(strlen(string)+1);
		strcpy(pair->key,string);
		
		c = FindQuote(fp);
		CopyUntilQuote(fp,string);
		pair->value = malloc(strlen(string)+1);
		strcpy(pair->value,string);
		
		[list addPointer:pair];
		c = FindBrace(fp);
	}
	
	return self;
}

- (void)dealloc
{
    for(NSUInteger i = 0; i < list.count; i++)
    {
        dict_t* d = [list pointerAtIndex:i];
        
        free(d->value);
        free(d->key);
        
        free(d);
    }
}
@end

//===============================================
//
//	C routines for string parsing
//
//===============================================
int	GetNextChar(FILE *fp)
{
	int		c;
	int		c2;
	
	c = getc(fp);
	if (c == EOF)
		return -1;
	if (c == '/')		// parse comments
	{
		c2 = getc(fp);
		if (c2 == '/')
		{
			while((c2 = getc(fp)) != '\n');
			c = getc(fp);
		}
		else
			ungetc(c2,fp);
	}
	return c;
}

void CopyUntilWhitespc(FILE *fp,char *buffer)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return;
		if (c <= ' ')
		{
			*buffer = 0;
			return;
		}
		*buffer++ = c;
	}
}

void CopyUntilQuote(FILE *fp,char *buffer)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return;
		if (c == '\"')
		{
			*buffer = 0;
			return;
		}
		*buffer++ = c;
	}
}

int FindBrace(FILE *fp)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c == '{' ||
			c == '}')
			return c;
	}
	return -1;
}

int FindQuote(FILE *fp)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c == '\"')
			return c;
	}
	return -1;
}

int FindWhitespc(FILE *fp)
{
	int	count = 800;
	int	c;
		
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c <= ' ')
		{
			ungetc(c,fp);
			return c;
		}
	}
	return -1;		
}

int FindNonwhitespc(FILE *fp)
{
	int	count = 800;
	int	c;
		
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c > ' ')
		{
			ungetc(c,fp);
			return c;
		}
	}
	return -1;
}

char *FindWhitespcInBuffer(char *buffer)
{
	int	count = 1000;
	char	*b = buffer;
	
	while(count--)
		if (*b <= ' ')
			return b;
		else
			b++;
	return NULL;		
}

char *FindNonwhitespcInBuffer(char *buffer)
{
	int	count = 1000;
	char	*b = buffer;
	
	while(count--)
		if (*b > ' ')
			return b;
		else
			b++;
	return NULL;
}
