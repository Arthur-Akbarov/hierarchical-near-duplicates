
# archetype 1234567
This function is called .*? object .*?\nWhen the real object is .*?tracked by debugobjects

# specific 12356 from 123567
it is checked, whether the object can be \w+\. \w+ is not allowed for active .*?objects\. When debugobjects detects an error, then it calls the fixup_\w+ function of the object type description structure if provided by the caller\. The fixup function can correct the problem before the real \w+ of the object happens\. E\.g\. it can deactivate an active object in order to prevent damage to the subsystem\.
# archetype 12356
This function is called .*? object .*?\nWhen the real object is .*?tracked by debugobjects it is checked, whether the object can be \w+\. \w+ is not allowed for active .*?objects\. When debugobjects detects an error, then it calls the fixup_\w+ function of the object type description structure if provided by the caller\. The fixup function can correct the problem before the real \w+ of the object happens\. E\.g\. it can deactivate an active object in order to prevent damage to the subsystem\.

# specific 123 from 12356
whenever the \w+ function of a real .*? is called\.\n.*?already.*?and destroyed.*?\nWhen the real object is not yet tracked by debugobjects
# archetype 123
This function is called whenever the \w+ function of a real object.*? is called\.\nWhen the real object is already tracked by debugobjects it is checked, whether the object can be \w+\. \w+ is not allowed for active and destroyed objects\. When debugobjects detects an error, then it calls the fixup_\w+ function of the object type description structure if provided by the caller\. The fixup function can correct the problem before the real \w+ of the object happens\. E\.g\. it can deactivate an active object in order to prevent damage to the subsystem\.\nWhen the real object is not yet tracked by debugobjects

# specific 12 from 123
initialization.*?\n.*?initialized.*?Initializing.*?init.*?initialization.*?\n.*?debugobjects allocates a tracker object for the real object and sets the tracker object state to ODEBUG_STATE_INIT\. It verifies that the object is (not )?on the callers stack\.
# archetype 12
This function is called whenever the initialization function of a real object.*? is called\.\nWhen the real object is already tracked by debugobjects it is checked, whether the object can be initialized\. Initializing is not allowed for active and destroyed objects\. When debugobjects detects an error, then it calls the fixup_init function of the object type description structure if provided by the caller\. The fixup function can correct the problem before the real initialization of the object happens\. E\.g\. it can deactivate an active object in order to prevent damage to the subsystem\.\nWhen the real object is not yet tracked by debugobjects,? debugobjects allocates a tracker object for the real object and sets the tracker object state to ODEBUG_STATE_INIT\. It verifies that the object is (not )?on the callers stack\.
